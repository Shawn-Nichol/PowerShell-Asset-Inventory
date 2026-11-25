function Repair-WinRM
{
    <#
    .SYNOPSIS
        Tries to enable WinRM on a remote computer using PsExec.

    .DESCRIPTION
        This changes the target's configuration (enables PowerShell remoting
        and sets the WinRM service to start automatically), so
        Start-Inventory.ps1 only calls it when -RepairWinRM is specified.
        Requires PsExec (Sysinternals) on the PATH and admin rights on the target.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$ComputerName
    )

    if (-not (Get-Command -Name 'psexec' -ErrorAction SilentlyContinue))
    {
        Write-Warning "$ComputerName - Cannot repair WinRM: PsExec was not found on the PATH."
        return $false
    }

    Write-Warning "$ComputerName - Attempting WinRM repair with PsExec"

    $RemoteCommand =
        'Enable-PSRemoting -Force; ' +
        'Set-Service -Name WinRM -StartupType Automatic; ' +
        'Start-Service -Name WinRM'

    & psexec "\\$ComputerName" -accepteula -nobanner -s powershell.exe -NoProfile -Command $RemoteCommand *> $null

    Start-Sleep -Seconds 5

    if (Test-WinRM -ComputerName $ComputerName)
    {
        Write-Verbose "$ComputerName - WinRM repaired"
        return $true
    }

    Write-Warning "$ComputerName - WinRM repair failed"
    return $false
}
