function New-BaseRecord
{
    param
    (
        [string]$ComputerName,

        [string]$OS = "",

        [string]$AutoLogonUser = "",

        [string]$MachineType = "",

        [string]$OnAirOffice = "",

        [string]$AddressType = "",

        [string]$WheatstoneIP = "",

        [string]$Notes = ""
    )

    @{
        "Server / Workstation Name" = $ComputerName
        "OS" = $OS
        "Primary User / Service Account Name" = $AutoLogonUser
        "VM / BM / HW" = $MachineType
        "On-Air or Office" = $OnAirOffice
        "Static IP or DHCP" = $AddressType
        "Wheatstone" = $WheatstoneIP
        "Notes" = $Notes
    }
}