#Requires -Version 5.1

<#
.SYNOPSIS
    Inventories broadcast applications, licensing and system details across
    Windows computers and exports the results to CSV.

.DESCRIPTION
    For each target computer, Start-Inventory.ps1:
      1. Checks that the computer answers WinRM (PowerShell remoting)
      2. Reports it as Offline if it does not respond at all
      3. Optionally repairs WinRM with PsExec (-RepairWinRM)
      4. Runs the audit on all reachable computers in parallel
      5. Writes one row per tracked application to a timestamped CSV

    The local computer is audited directly, without remoting.
    Every target appears in the report, either with its applications or
    with a note explaining why it could not be audited.

.PARAMETER ComputerName
    One or more computers to audit. Overrides the computer list file.

.PARAMETER ComputerListPath
    Text file with one hostname per line. Defaults to Config\Computers.txt.
    If the file does not exist and -ComputerName is not given, only the
    local computer is audited.

.PARAMETER ApplicationsPath
    Data file listing the applications to track. Defaults to Config\Applications.psd1.

.PARAMETER NetworkPath
    Data file with environment-specific subnets. Defaults to Config\Network.psd1.

.PARAMETER OutputPath
    Folder for the CSV report. Defaults to the Output folder next to this script.

.PARAMETER RepairWinRM
    Try to enable WinRM with PsExec on computers that respond to ping but
    not to WinRM. This changes the remote computer's configuration.

.PARAMETER Credential
    Credential for the remote connections. Defaults to the current user.

.EXAMPLE
    .\Start-Inventory.ps1

    Audits every computer in Config\Computers.txt (or just this computer
    if the file does not exist).

.EXAMPLE
    .\Start-Inventory.ps1 -ComputerName STUDIO-01, STUDIO-02 -Verbose

    Audits two computers and shows progress details.

.EXAMPLE
    .\Start-Inventory.ps1 -RepairWinRM -Credential (Get-Credential)

    Audits the computer list with alternate credentials and tries to fix
    WinRM where it is not responding.
#>

[CmdletBinding()]
param
(
    [string[]]$ComputerName,

    [string]$ComputerListPath = (Join-Path -Path $PSScriptRoot -ChildPath 'Config\Computers.txt'),

    [string]$ApplicationsPath = (Join-Path -Path $PSScriptRoot -ChildPath 'Config\Applications.psd1'),

    [string]$NetworkPath = (Join-Path -Path $PSScriptRoot -ChildPath 'Config\Network.psd1'),

    [string]$OutputPath = (Join-Path -Path $PSScriptRoot -ChildPath 'Output'),

    [switch]$RepairWinRM,

    [System.Management.Automation.PSCredential]$Credential
)

$ErrorActionPreference = 'Stop'

# Load helper functions.
#   Private\ runs on this computer only.
#   Remote\  runs on each target, and is also loaded here for shared helpers.
$PrivatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
$RemotePath  = Join-Path -Path $PSScriptRoot -ChildPath 'Remote'

foreach ($File in Get-ChildItem -Path $PrivatePath, $RemotePath -Filter '*.ps1')
{
    . $File.FullName
}

# Package the Remote\ functions into one script block that can be sent to
# each target. Functions loaded here do not exist in a remote session, so
# they have to travel with the command.
$RemoteCode = Get-ChildItem -Path $RemotePath -Filter '*.ps1' |
    ForEach-Object { Get-Content -Path $_.FullName -Raw }

$RemoteScript = [scriptblock]::Create(
    "param(`$Settings)`r`n" +
    ($RemoteCode -join "`r`n") +
    "`r`nInvoke-RemoteInventory -Settings `$Settings"
)

$Settings = Import-InventorySettings -ApplicationsPath $ApplicationsPath -NetworkPath $NetworkPath
$Targets  = @(Get-TargetComputer -ComputerName $ComputerName -ListPath $ComputerListPath)

if ($Targets.Count -eq 0)
{
    throw "No computers to audit. Check $ComputerListPath or use -ComputerName."
}

Write-Host "Auditing $($Targets.Count) computer(s)..." -ForegroundColor Cyan

$Records       = [System.Collections.Generic.List[object]]::new()
$RemoteTargets = [System.Collections.Generic.List[string]]::new()

# Sort targets: audit the local computer directly, skip unreachable ones,
# and queue the rest for remoting.
foreach ($Computer in $Targets)
{
    if (Test-IsLocalComputer -ComputerName $Computer)
    {
        Write-Verbose "$Computer - auditing locally"

        foreach ($Record in & $RemoteScript $Settings)
        {
            $Records.Add($Record)
        }

        continue
    }

    $WinRMReady = Test-WinRM -ComputerName $Computer

    if (-not $WinRMReady)
    {
        if (-not (Test-Connection -ComputerName $Computer -Count 1 -Quiet -ErrorAction SilentlyContinue))
        {
            Write-Warning "$Computer - Offline"
            $Records.Add((New-AuditRecord -Base (New-BaseRecord -ComputerName $Computer) -Notes 'Offline'))
                continue
        }

        if ($RepairWinRM)
        {
            $WinRMReady = Repair-WinRM -ComputerName $Computer
        }
    }

    if (-not $WinRMReady)
    {
        Write-Warning "$Computer - WinRM unavailable"
        $Records.Add((New-AuditRecord -Base (New-BaseRecord -ComputerName $Computer) `
            -Notes 'WinRM unavailable (run with -RepairWinRM to attempt a fix)'))
        continue
    }

    $RemoteTargets.Add($Computer)
}

# Audit all reachable computers in parallel.
if ($RemoteTargets.Count -gt 0)
{
    Write-Verbose "Running remote audit on $($RemoteTargets.Count) computer(s)"

    $InvokeParams = @{
        ComputerName  = $RemoteTargets.ToArray()
        ScriptBlock   = $RemoteScript
        ArgumentList  = @($Settings)
        ErrorAction   = 'SilentlyContinue'
        ErrorVariable = 'RemoteErrors'
    }

    if ($Credential)
    {
        $InvokeParams.Credential = $Credential
    }

    $RemoteResults = @(Invoke-Command @InvokeParams)

    foreach ($Record in $RemoteResults)
    {
        $Records.Add($Record)
    }

    # Any computer that returned nothing failed to connect or run; add a row
    # so it does not silently disappear from the report.
    $Responded = @($RemoteResults | ForEach-Object { $_.PSComputerName } | Sort-Object -Unique)

    foreach ($Computer in $RemoteTargets)
    {
        if ($Responded -contains $Computer)
        {
            continue
        }

        $RemoteError = $RemoteErrors |
            Where-Object {
                $_.TargetObject -eq $Computer -or
                ($_.OriginInfo -and $_.OriginInfo.PSComputerName -eq $Computer)
            } |
            Select-Object -First 1

        $Message = 'No data returned'
        if ($RemoteError) { $Message = $RemoteError.Exception.Message }

        Write-Warning "$Computer - $Message"
        $Records.Add((New-AuditRecord -Base (New-BaseRecord -ComputerName $Computer) -Notes "Error: $Message"))
    }
}

$ReportPath = Export-InventoryReport -Records $Records.ToArray() -OutputPath $OutputPath

$ProblemComputers = @(
    $Records |
        Where-Object { $_.Notes -like 'Offline*' -or $_.Notes -like 'WinRM*' -or $_.Notes -like 'Error:*' } |
        ForEach-Object { $_.'Server / Workstation Name' } |
        Sort-Object -Unique
)

Write-Host ''
Write-Host "Computers         : $($Targets.Count)" -ForegroundColor Cyan
Write-Host "Need attention    : $($ProblemComputers.Count) (offline, WinRM or errors - see Notes column)" -ForegroundColor Cyan
Write-Host "Report rows       : $($Records.Count)" -ForegroundColor Cyan
Write-Host ''
Write-Host 'CSV exported to:' -ForegroundColor Green
Write-Host $ReportPath -ForegroundColor Cyan
