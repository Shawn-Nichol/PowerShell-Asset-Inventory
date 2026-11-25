function New-AuditRecord
{
    <#
    .SYNOPSIS
        Creates one report row: the computer details plus one application.

    .DESCRIPTION
        The property names and order here define the CSV columns:
        computer, hardware, users, network, security, application,
        licensing and remote access, then notes.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [hashtable]$Base,

        [string]$ApplicationName = '',
        [string]$Functionality = '',
        [string]$UserType = '',
        [string]$ServiceType = '',
        [string]$Executable = '',
        [string]$Version = '',
        [string]$LicenseType = '',
        [string]$HaspID = '',
        [string]$TeamViewerID = '',
        [string]$Notes = ''
    )

    [PSCustomObject]@{
        # Computer
        'Server / Workstation Name'                     = $Base.ComputerName
        'On-Air or Office'                              = $Base.Location
        'Time Zone'                                     = $Base.TimeZone
        'OS'                                            = $Base.OS
        'VM / BM / HW'                                  = $Base.MachineType
        'Serial Number'                                 = $Base.SerialNumber
        'BIOS Manufacturer'                             = $Base.BiosManufacturer
        'BIOS Version'                                  = $Base.BiosVersion
        'BIOS Release Date'                             = $Base.BiosReleaseDate

        # Hardware
        'CPU'                                           = $Base.CPU
        'RAM (GB)'                                      = $Base.RamGB
        'C: Size (GB)'                                  = $Base.DiskSizeGB
        'C: Free (GB)'                                  = $Base.DiskFreeGB

        # Users
        'Auto-Logon Enabled'                            = $Base.AutoLogonEnabled
        'Auto-Logon User'                               = $Base.AutoLogonUser
        'Last Logged-On User'                           = $Base.LastLoggedOnUser

        # Network
        'Static IP or DHCP'                             = $Base.AddressType
        'Wheatstone'                                    = $Base.WheatstoneIP

        # Security
        'Secure Boot'                                   = $Base.SecureBoot
        'TPM'                                           = $Base.Tpm
        'BitLocker (C:)'                                = $Base.BitLocker
        'RDP'                                           = $Base.Rdp
        'SMBv1'                                         = $Base.Smb1
        'Firewall'                                      = $Base.Firewall
        'Reboot Pending'                                = $Base.RebootPending

        # Application
        'Application Name'                              = $ApplicationName
        'Version'                                       = $Version
        'Functionality'                                 = $Functionality
        'End User / Server / Service'                   = $UserType
        'Service / App'                                 = $ServiceType
        'Executable / startup'                          = $Executable

        # Licensing and remote access
        'Network HASP, Dedicated HASP, by File (codes)' = $LicenseType
        'Hasp ID'                                       = $HaspID
        'TeamViewer ID'                                 = $TeamViewerID

        'Notes'                                         = $Notes
    }
}
