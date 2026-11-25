function Get-FirewallStatus
{
    <#
    .SYNOPSIS
        Returns the state of each Windows Firewall profile, for example
        'Domain: On, Private: On, Public: Off'.
    #>
    [CmdletBinding()]
    param()

    $States = @{ 'True' = 'On'; 'False' = 'Off'; 'NotConfigured' = 'Not configured' }

    try
    {
        $Profiles = Get-NetFirewallProfile -ErrorAction Stop |
            ForEach-Object { '{0}: {1}' -f $_.Name, $States["$($_.Enabled)"] }

        $Profiles -join ', '
    }
    catch
    {
        'Unknown'
    }
}
