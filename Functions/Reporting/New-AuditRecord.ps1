function New-AuditRecord
{
    <#
    .SYNOPSIS
        Creates one report row: the machine details plus one application.

    .DESCRIPTION
        The property names and order here define the CSV columns.
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
        [string]$Notes = ''
    )

    [PSCustomObject]@{
        'Server / Workstation Name'                     = $Base.ComputerName
        'On-Air or Office'                              = $Base.Location
        'OS'                                            = $Base.OS
        'VM / BM / HW'                                  = $Base.MachineType
        'Primary User / Service Account Name'           = $Base.PrimaryUser
        'Static IP or DHCP'                             = $Base.AddressType
        'Wheatstone'                                    = $Base.WheatstoneIP
        'Application Name'                              = $ApplicationName
        'Version'                                       = $Version
        'Functionality'                                 = $Functionality
        'End User / Server / Service'                   = $UserType
        'Service / App'                                 = $ServiceType
        'Executable / startup'                          = $Executable
        'Network HASP, Dedicated HASP, by File (codes)' = $LicenseType
        'Hasp ID'                                       = $HaspID
        'Notes'                                         = $Notes
    }
}
