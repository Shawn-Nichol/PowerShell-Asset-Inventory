function Get-Smb1Status
{
    <#
    .SYNOPSIS
        Returns whether the SMBv1 server protocol is 'Enabled' or 'Disabled'.

    .DESCRIPTION
        SMBv1 is outdated and was used by WannaCry and NotPetya; it should
        normally be disabled.
    #>
    [CmdletBinding()]
    param()

    $Statuses = @{ 'True' = 'Enabled'; 'False' = 'Disabled' }

    try
    {
        $Config = Get-SmbServerConfiguration -ErrorAction Stop

        [string](Get-ValueOrDefault -Value $Statuses["$($Config.EnableSMB1Protocol)"] -Default 'Unknown')
    }
    catch
    {
        'Unknown'
    }
}
