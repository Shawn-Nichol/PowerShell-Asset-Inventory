function Get-NetworkInfo
{
    <#
    .SYNOPSIS
        Returns the primary IP, subnet mask, default gateway, addressing type,
        location, Wheatstone IP and any other IPv4 addresses of this computer.

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

    # Subnet mask from the prefix length, e.g. 24 -> 255.255.255.0 (/24).
    $PrefixLength = [int](@($PrimaryAdapter.IPv4Address.PrefixLength) | Select-Object -First 1)
    $MaskBits     = ('1' * $PrefixLength).PadRight(32, '0')
    $MaskOctets   = 0..3 | ForEach-Object { [Convert]::ToInt32($MaskBits.Substring($_ * 8, 8), 2) }
    $SubnetMasks  = @{ $true = '{0} (/{1})' -f ($MaskOctets -join '.'), $PrefixLength; $false = '' }
    $SubnetMask   = $SubnetMasks[$PrefixLength -gt 0]

    $DefaultGateway = @($PrimaryAdapter.IPv4DefaultGateway.NextHop | Where-Object { $_ }) -join '; '

    $AddressTypes = @{ 'Enabled' = 'DHCP'; 'Disabled' = 'Static' }
    $AddressType  = [string]$AddressTypes["$($PrimaryAdapter.NetIPv4Interface.Dhcp)"]

    $IsOnAir   = [bool]($OnAirSubnet -and $IPAddress -like $OnAirSubnet)
    $Locations = @{ $true = 'On-Air'; $false = 'Office' }

    $WheatstoneIP = [string](
        $Adapters.IPv4Address.IPAddress |
            Where-Object { $WheatstoneSubnet -and $_ -like $WheatstoneSubnet } |
            Select-Object -First 1
    )

    # Every other address, ignoring loopback and self-assigned (169.254.x.x).
    $OtherIPAddresses = $Adapters.IPv4Address.IPAddress |
        Where-Object { $_ -and $_ -notin @($IPAddress, $WheatstoneIP) } |
        Where-Object { $_ -notlike '127.*' -and $_ -notlike '169.254.*' } |
        Sort-Object -Unique

    [PSCustomObject]@{
        IPAddress        = $IPAddress
        SubnetMask       = $SubnetMask
        DefaultGateway   = $DefaultGateway
        AddressType      = $AddressType
        Location         = $Locations[$IsOnAir]
        WheatstoneIP     = $WheatstoneIP
        OtherIPAddresses = @($OtherIPAddresses) -join '; '
    }
}
