function Get-RdpStatus
{
    <#
    .SYNOPSIS
        Returns whether Remote Desktop connections are 'Enabled' or 'Disabled'.
    #>
    [CmdletBinding()]
    param()

    $TerminalServer = Get-ItemProperty `
        -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' `
        -ErrorAction SilentlyContinue

    # fDenyTSConnections = 0 means connections are allowed.
    $Statuses = @{ '0' = 'Enabled'; '1' = 'Disabled' }

    [string](Get-ValueOrDefault -Value $Statuses["$($TerminalServer.fDenyTSConnections)"] -Default 'Unknown')
}
