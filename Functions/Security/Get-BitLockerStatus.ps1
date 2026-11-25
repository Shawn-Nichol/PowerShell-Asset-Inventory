function Get-BitLockerStatus
{
    <#
    .SYNOPSIS
        Returns BitLocker protection on the C: drive: 'On', 'Off', or 'Not available'.

    .DESCRIPTION
        'Off' includes drives where BitLocker is suspended. 'Not available'
        means BitLocker is not installed or the status could not be read.
    #>
    [CmdletBinding()]
    param()

    $Statuses = @{ '0' = 'Off'; '1' = 'On'; '2' = 'Unknown' }

    try
    {
        $Volume = Get-CimInstance `
            -Namespace 'root\cimv2\Security\MicrosoftVolumeEncryption' `
            -ClassName Win32_EncryptableVolume `
            -Filter "DriveLetter='C:'" `
            -ErrorAction Stop

        [string](Get-ValueOrDefault -Value $Statuses["$($Volume.ProtectionStatus)"] -Default 'Not available')
    }
    catch
    {
        'Not available'
    }
}
