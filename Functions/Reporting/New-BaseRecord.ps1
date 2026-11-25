function New-BaseRecord
{
    <#
    .SYNOPSIS
        Creates the computer-level details shared by every row for a computer.

    .DESCRIPTION
        Every key starts empty, so a computer that could not be audited still
        produces a complete row. Values in -Details replace the empty defaults.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$ComputerName,

        [hashtable]$Details = @{}
    )

    $Base = @{
        ComputerName     = $ComputerName
        Location         = ''
        TimeZone         = ''
        OS               = ''
        MachineType      = ''
        SerialNumber     = ''
        BiosManufacturer = ''
        BiosVersion      = ''
        BiosReleaseDate  = ''
        CPU              = ''
        RamGB            = ''
        DiskSizeGB       = ''
        DiskFreeGB       = ''
        AutoLogonEnabled = ''
        AutoLogonUser    = ''
        LastLoggedOnUser = ''
        IPAddress        = ''
        SubnetMask       = ''
        DefaultGateway   = ''
        AddressType      = ''
        OtherIPAddresses = ''
        WheatstoneIP     = ''
        SecureBoot       = ''
        Tpm              = ''
        BitLocker        = ''
        Rdp              = ''
        Smb1             = ''
        Firewall         = ''
        RebootPending    = ''
    }

    foreach ($Key in $Details.Keys)
    {
        $Base[$Key] = [string]$Details[$Key]
    }

    $Base
}
