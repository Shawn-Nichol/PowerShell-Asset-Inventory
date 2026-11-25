function Get-InstalledApplications
{
    $BroadcastApps = @(
        "WideOrbit",
        "Burli",
        "Dav",
        "iMedia",
        "Logger",
        "DJB",
        "CSRDS",
        "Arctic Palm",
        "Nautel",
        "Sage",
        "VMix",
        "VoxPro",
        "ProTools",
        "LeanEncoder",
        "DreamEncoder",
        "GV Stratus",
        "Stratus",
        "OpenMedia"
    )

    $InstalledApps =
        Get-ItemProperty `
            HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,
            HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
            -ErrorAction SilentlyContinue |

        Where-Object {

            $DisplayName = [string]$_.DisplayName

            foreach ($App in $BroadcastApps)
            {
                if ($DisplayName -like "*$App*")
                {
                    return $true
                }
            }

            $false
        }

    return $InstalledApps
}