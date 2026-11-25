function Get-SecurityInfo
{
    <#
    .SYNOPSIS
        Collects the security settings reported for each computer.
    #>
    [CmdletBinding()]
    param()

    [PSCustomObject]@{
        SecureBoot    = Get-SecureBootStatus
        Tpm           = Get-TpmStatus
        BitLocker     = Get-BitLockerStatus
        Rdp           = Get-RdpStatus
        Smb1          = Get-Smb1Status
        Firewall      = Get-FirewallStatus
        RebootPending = Get-RebootPending
    }
}
