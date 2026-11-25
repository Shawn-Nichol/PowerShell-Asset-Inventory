function New-AuditRecord
{
    param
    (
        [hashtable]$Base,

        [string]$ApplicationName = "",

        [string]$Functionality = "",

        [string]$UserType = "",

        [string]$ServiceType = "",

        [string]$Executable = "",

        [string]$Version = "",

        [string]$LicenseType = "",

        [string]$HaspID = "",

        [string]$Notes = ""
    )

    [PSCustomObject]@{

        "Application Name" = $ApplicationName

        "Functionality" = $Functionality

        "End User / Server / Service" = $UserType

        "Service / App" = $ServiceType

        "Executable / startup" = $Executable

        "Version" = $Version

        "Network HASP, Dedicated HASP, by File (codes)" = $LicenseType

        "Hasp ID" = $HaspID

        "Server / Workstation Name" =
            $Base["Server / Workstation Name"]

        "OS" =
            $Base["OS"]

        "Primary User / Service Account Name" =
            $Base["Primary User / Service Account Name"]

        "VM / BM / HW" =
            $Base["VM / BM / HW"]

        "On-Air or Office" =
            $Base["On-Air or Office"]

        "Static IP or DHCP" =
            $Base["Static IP or DHCP"]

        "Wheatstone" =
            $Base["Wheatstone"]

        "Notes" = $Notes
    }
}