function Get-BiosInfo
{
    <#
    .SYNOPSIS
        Returns the BIOS manufacturer, version, release date and the
        computer's serial number.
    #>
    [CmdletBinding()]
    param()

    $Bios = Get-CimInstance -ClassName Win32_BIOS

    $ReleaseDate = $Bios.ReleaseDate |
        Where-Object { $_ } |
        ForEach-Object { $_.ToString('yyyy-MM-dd') }

    [PSCustomObject]@{
        Manufacturer = "$($Bios.Manufacturer)".Trim()
        Version      = "$($Bios.SMBIOSBIOSVersion)".Trim()
        ReleaseDate  = [string]$ReleaseDate
        SerialNumber = "$($Bios.SerialNumber)".Trim()
    }
}
