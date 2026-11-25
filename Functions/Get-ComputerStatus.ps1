function Get-ComputerStatus
{
    <#
    .SYNOPSIS
        Decides how a computer will be audited.

    .OUTPUTS
        'Local'             - this computer; audited directly
        'Ready'             - answers WinRM; audited remotely
        'Offline'           - does not respond to WinRM or ping
        'WinRM unavailable' - responds to ping but not WinRM
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$ComputerName,

        [switch]$RepairWinRM
    )

    if (Test-IsLocalComputer -ComputerName $ComputerName) { return 'Local' }

    if (Test-WinRM -ComputerName $ComputerName) { return 'Ready' }

    $Online = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction SilentlyContinue

    if (-not $Online)
    {
        Write-Warning "$ComputerName - Offline"
        return 'Offline'
    }

    if ($RepairWinRM -and (Repair-WinRM -ComputerName $ComputerName)) { return 'Ready' }

    Write-Warning "$ComputerName - WinRM unavailable (run with -RepairWinRM to attempt a fix)"
    return 'WinRM unavailable'
}
