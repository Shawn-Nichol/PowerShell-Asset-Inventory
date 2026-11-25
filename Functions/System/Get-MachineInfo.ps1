function Get-MachineInfo
{
    <#
    .SYNOPSIS
        Collects the computer-level details shared by every row for this computer.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [hashtable]$Network
    )

    $System   = Get-SystemInfo
    $Bios     = Get-BiosInfo
    $Hardware = Get-HardwareInfo
    $Logon    = Get-LogonInfo
    $Security = Get-SecurityInfo

    $NetworkInfo = Get-NetworkInfo `
        -PrimarySubnet $Network.PrimarySubnet `
        -OnAirSubnet $Network.OnAirSubnet `
        -WheatstoneSubnet $Network.WheatstoneSubnet

    $Details = @{
        Location         = $NetworkInfo.Location
        OS               = $System.OS
        MachineType      = $System.MachineType
        SerialNumber     = $Bios.SerialNumber
        BiosManufacturer = $Bios.Manufacturer
        BiosVersion      = $Bios.Version
        BiosReleaseDate  = $Bios.ReleaseDate
        CPU              = $Hardware.CPU
        RamGB            = $Hardware.RamGB
        DiskSizeGB       = $Hardware.DiskSizeGB
        DiskFreeGB       = $Hardware.DiskFreeGB
        AutoLogonEnabled = $Logon.AutoLogonEnabled
        AutoLogonUser    = $Logon.AutoLogonUser
        LastLoggedOnUser = $Logon.LastLoggedOnUser
        AddressType      = $NetworkInfo.AddressType
        WheatstoneIP     = $NetworkInfo.WheatstoneIP
        SecureBoot       = $Security.SecureBoot
        Tpm              = $Security.Tpm
        BitLocker        = $Security.BitLocker
        Rdp              = $Security.Rdp
        Smb1             = $Security.Smb1
        Firewall         = $Security.Firewall
        RebootPending    = $Security.RebootPending
    }

    New-BaseRecord -ComputerName $env:COMPUTERNAME -Details $Details
}
