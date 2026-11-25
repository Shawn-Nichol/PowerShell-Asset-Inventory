function Get-HaspLicenseType
{
    <#
    .SYNOPSIS
        Asks the local Sentinel HASP License Manager whether the license key
        is attached locally (Dedicated HASP) or served over the network.

    .OUTPUTS
        'Dedicated HASP', 'Network HASP', or '' when it cannot be determined.
    #>
    [CmdletBinding()]
    param()

    try
    {
        $Response = Invoke-WebRequest `
            -Uri 'http://localhost:1947/_int_/tab_dev.html' `
            -UseBasicParsing `
            -TimeoutSec 5 `
            -ErrorAction Stop

        if ($Response.Content -match '"isloc":"1"')
        {
            return 'Dedicated HASP'
        }

        if ($Response.Content -match '"isloc":"0"')
        {
            return 'Network HASP'
        }
    }
    catch
    {
        Write-Verbose "HASP License Manager not reachable: $($_.Exception.Message)"
    }

    return ''
}
