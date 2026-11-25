function Get-NetworkInfo
{
    <#
    .SYNOPSIS
        Returns the primary IP, addressing type, location and Wheatstone IP
        of this computer.

    .PARAMETER PrimarySubnet
        Wildcard pattern for the main adapter's IPv4 address. When empty, or
        when nothing matches, the adapter with a default gateway is used.

    .PARAMETER OnAirSubnet
        Wildcard pattern. A primary IP that matches is reported as On-Air.

    .PARAMETER WheatstoneSubnet
        Wildcard pattern for the Wheatstone audio network adapter.
    #>
    [CmdletBinding()]
    param
    (
        [string]$PrimarySubnet = '',
        [string]$OnAirSubnet = '',
        [string]$WheatstoneSubnet = ''
    )

    $Adapters = @(Get-NetIPConfiguration | Where-Object IPv4Address)

    # First adapter in the primary subnet, otherwise the one with a gateway.
    $PrimaryAdapter = @(
        $Adapters | Where-Object { $PrimarySubnet -and $_.IPv4Address.IPAddress -like $PrimarySubnet }
        $Adapters | Where-Object IPv4DefaultGateway
    ) | Select-Object -First 1

    $IPAddress = [string](@($PrimaryAdapter.IPv4Address.IPAddress) | Select-Object -First 1)

    $AddressTypes = @{ 'Enabled' = 'DHCP'; 'Disabled' = 'Static' }
    $AddressType  = [string]$AddressTypes["$($PrimaryAdapter.NetIPv4Interface.Dhcp)"]

    $IsOnAir   = [bool]($OnAirSubnet -and $IPAddress -like $OnAirSubnet)
    $Locations = @{ $true = 'On-Air'; $false = 'Office' }

    $WheatstoneIP = [string](
        $Adapters.IPv4Address.IPAddress |
            Where-Object { $WheatstoneSubnet -and $_ -like $WheatstoneSubnet } |
            Select-Object -First 1
    )

    [PSCustomObject]@{
        IPAddress    = $IPAddress
        AddressType  = $AddressType
        Location     = $Locations[$IsOnAir]
        WheatstoneIP = $WheatstoneIP
    }
}
