function Get-BurliInfo
{
$BurliInstalled = $false

$BurliHaspID = ""

$BurliLicenseType = ""

$BurliInstalled = Test-Path `
    "HKLM:\Software\WOW6432Node\Burli\RadioStar"


    if ($BurliInstalled)
    {
        $BurliInternet = Get-ItemProperty `
            "HKLM:\Software\WOW6432Node\Burli\RadioStar\Internet" `
            -ErrorAction SilentlyContinue

        $BurliHaspID = $BurliInternet."Unique ID"
    }

    try
    {
        $Content =
        (
            Invoke-WebRequest `
                "http://localhost:1947/_int_/tab_dev.html" `
                -UseBasicParsing
        ).Content

        if ($Content -match '"isloc":"1"')
        {
            $BurliLicenseType = "Dedicated HASP"
        }
        elseif ($Content -match '"isloc":"0"')
        {
            $BurliLicenseType = "Network HASP"
        }
    }
    catch
    {
    }

    [PSCustomObject]@{

        Installed = $BurliInstalled

        HaspID = $BurliHaspID

        LicenseType = $BurliLicenseType
    }
}
