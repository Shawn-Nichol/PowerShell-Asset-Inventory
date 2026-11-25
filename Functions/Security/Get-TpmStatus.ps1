function Get-TpmStatus
{
    <#
    .SYNOPSIS
        Returns the TPM version and whether it is enabled, for example
        '2.0 (Enabled)', 'Not found', or 'Unknown' if it cannot be read.
    #>
    [CmdletBinding()]
    param()

    $EnabledStates = @{ 'True' = 'Enabled'; 'False' = 'Disabled' }

    try
    {
        $Status = Get-CimInstance `
            -Namespace 'root\cimv2\Security\MicrosoftTpm' `
            -ClassName Win32_Tpm `
            -ErrorAction Stop |
            ForEach-Object {
                # SpecVersion looks like "2.0, 0, 1.59"; the first part is the version.
                $Version = ("$($_.SpecVersion)" -split ',')[0].Trim()
                '{0} ({1})' -f $Version, $EnabledStates["$($_.IsEnabled_InitialValue)"]
            }

        [string](Get-ValueOrDefault -Value $Status -Default 'Not found')
    }
    catch
    {
        'Unknown'
    }
}
