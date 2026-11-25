function New-BaseRecord
{
    <#
    .SYNOPSIS
        Creates the machine-level details shared by every row for a computer.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$ComputerName,

        [string]$OS = '',
        [string]$PrimaryUser = '',
        [string]$MachineType = '',
        [string]$Location = '',
        [string]$AddressType = '',
        [string]$WheatstoneIP = ''
    )

    @{
        ComputerName = $ComputerName
        OS           = $OS
        PrimaryUser  = $PrimaryUser
        MachineType  = $MachineType
        Location     = $Location
        AddressType  = $AddressType
        WheatstoneIP = $WheatstoneIP
    }
}
