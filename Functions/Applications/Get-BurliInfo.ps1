function Get-BurliInfo
{
    <#
    .SYNOPSIS
        Returns whether Burli is installed, its HASP ID and license type.
    #>
    [CmdletBinding()]
    param()

    $BurliKey = 'HKLM:\Software\WOW6432Node\Burli\RadioStar'

    $NotInstalled = [PSCustomObject]@{ Installed = $false; HaspID = ''; LicenseType = '' }

    if (-not (Test-Path -Path $BurliKey)) { return $NotInstalled }

    $Internet = Get-ItemProperty -Path "$BurliKey\Internet" -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Installed   = $true
        HaspID      = [string]$Internet.'Unique ID'
        LicenseType = Get-HaspLicenseType
    }
}
