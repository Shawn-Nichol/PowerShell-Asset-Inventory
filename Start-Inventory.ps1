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

# Load every function in the Functions folder.
$FunctionPath = Join-Path -Path $PSScriptRoot -ChildPath 'Functions'

foreach ($File in Get-ChildItem -Path $FunctionPath -Filter '*.ps1')
{
    . $File.FullName
}

# Functions loaded here do not exist on remote computers, so package them
# into one script block that is sent along with each remote command.
$InventoryScript = New-RemoteScript -FunctionPath $FunctionPath

$Settings = Import-InventorySettings -ApplicationsPath $ApplicationsPath -NetworkPath $NetworkPath
$Targets  = @(Get-TargetComputer -ComputerName $ComputerName -ListPath $ComputerListPath)

Write-Host "Checking $($Targets.Count) computer(s)..." -ForegroundColor Cyan

# Step 1: decide how to handle each computer (Local, Ready, Offline, WinRM unavailable).
$Checked = foreach ($Computer in $Targets)
{
    [PSCustomObject]@{
        ComputerName = $Computer
        Status       = Get-ComputerStatus -ComputerName $Computer -RepairWinRM:$RepairWinRM
    }
}

$LocalComputers   = @($Checked | Where-Object Status -eq 'Local')
$ReadyComputers   = @($Checked | Where-Object Status -eq 'Ready' | ForEach-Object ComputerName)
$SkippedComputers = @($Checked | Where-Object Status -notin 'Local', 'Ready')

# Step 2: collect the rows. Every computer produces at least one row.
$Records = @(
    $LocalComputers   | ForEach-Object { & $InventoryScript $Settings }
    $SkippedComputers | ForEach-Object { New-StatusRecord -ComputerName $_.ComputerName -Notes $_.Status }

    Invoke-InventoryRemoting `
        -ComputerName $ReadyComputers `
        -ScriptBlock $InventoryScript `
        -Settings $Settings `
        -Credential $Credential
)

# Step 3: export and summarise.
$ReportPath = Export-InventoryReport -Records $Records -OutputPath $OutputPath

Write-InventorySummary -Records $Records -ComputerCount $Targets.Count -ReportPath $ReportPath
