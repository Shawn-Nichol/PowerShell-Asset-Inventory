function Get-MachineInfo
{
    <#
    .SYNOPSIS
        Collects the machine-level details shared by every row for this computer.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [hashtable]$Network
    )

    $System = Get-SystemInfo

    $NetworkInfo = Get-NetworkInfo `
        -PrimarySubnet $Network.PrimarySubnet `
        -OnAirSubnet $Network.OnAirSubnet `
        -WheatstoneSubnet $Network.WheatstoneSubnet

    New-BaseRecord `
        -ComputerName $env:COMPUTERNAME `
        -OS $System.OS `
        -PrimaryUser (Get-AutoLogonUser) `
        -MachineType $System.MachineType `
        -Location $NetworkInfo.Location `
        -AddressType $NetworkInfo.AddressType `
        -WheatstoneIP $NetworkInfo.WheatstoneIP
}
