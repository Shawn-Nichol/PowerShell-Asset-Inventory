function Get-BurliInfo
{
    <#
    .SYNOPSIS
        Returns whether Burli is installed, its HASP ID and license type.
    #>
    [CmdletBinding()]
    param()

    $BurliKey = 'HKLM:\Software\WOW6432Node\Burli\RadioStar'

    $Info = [PSCustomObject]@{
        Installed   = $false
        HaspID      = ''
        LicenseType = ''
    }

    if (-not (Test-Path -Path $BurliKey))
    {
        return $Info
    }

    $Info.Installed = $true

    $Internet = Get-ItemProperty -Path "$BurliKey\Internet" -ErrorAction SilentlyContinue

    if ($Internet -and $Internet.'Unique ID')
    {
        $Info.HaspID = [string]$Internet.'Unique ID'
    }

    $Info.LicenseType = Get-HaspLicenseType

    return $Info
}
