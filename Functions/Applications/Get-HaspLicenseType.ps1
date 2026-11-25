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

    # The License Manager page reports "isloc":"1" for a local key.
    $LicenseTypes = @{ '1' = 'Dedicated HASP'; '0' = 'Network HASP' }

    try
    {
        $Content = (Invoke-WebRequest `
            -Uri 'http://localhost:1947/_int_/tab_dev.html' `
            -UseBasicParsing `
            -TimeoutSec 5 `
            -ErrorAction Stop).Content

        $IsLocal = [regex]::Match($Content, '"isloc":"(\d)"').Groups[1].Value

        [string]$LicenseTypes[$IsLocal]
    }
    catch
    {
        Write-Verbose "HASP License Manager not reachable: $($_.Exception.Message)"
        ''
    }
}
