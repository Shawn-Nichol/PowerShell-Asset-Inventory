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
        'Application Name'                              = $ApplicationName
        'Functionality'                                 = $Functionality
        'End User / Server / Service'                   = $UserType
        'Service / App'                                 = $ServiceType
        'Executable / startup'                          = $Executable
        'Version'                                       = $Version
        'Network HASP, Dedicated HASP, by File (codes)' = $LicenseType
        'Hasp ID'                                       = $HaspID
        'Server / Workstation Name'                     = $Base.ComputerName
        'OS'                                            = $Base.OS
        'Primary User / Service Account Name'           = $Base.PrimaryUser
        'VM / BM / HW'                                  = $Base.MachineType
        'On-Air or Office'                              = $Base.Location
        'Static IP or DHCP'                             = $Base.AddressType
        'Wheatstone'                                    = $Base.WheatstoneIP
        'Notes'                                         = $Notes
    }
}
