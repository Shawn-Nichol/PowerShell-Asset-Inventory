function Get-SecureBootStatus
{
    <#
    .SYNOPSIS
        Returns 'Enabled', 'Disabled', or 'Not supported' for legacy BIOS computers.

    .DESCRIPTION
        Reads the registry instead of Confirm-SecureBootUEFI, which throws an
        error on computers that do not boot with UEFI.
    #>
    [CmdletBinding()]
    param()

    $State = Get-ItemProperty `
        -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State' `
        -ErrorAction SilentlyContinue

    $Statuses = @{ '1' = 'Enabled'; '0' = 'Disabled'; '' = 'Not supported' }

    $Statuses["$($State.UEFISecureBootEnabled)"]
}
