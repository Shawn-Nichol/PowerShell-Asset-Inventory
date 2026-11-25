function Get-NetworkInfo
{
    <#
    .SYNOPSIS
        Returns the primary IP, addressing type, location and Wheatstone IP
        of the local machine.

    .PARAMETER PrimarySubnet
        Wildcard pattern for the main adapter's IPv4 address. When empty, the
        adapter with a default gateway is used.

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

    $Adapters = @(Get-NetIPConfiguration | Where-Object { $_.IPv4Address })

    $PrimaryAdapter = $null

    if ($PrimarySubnet)
    {
        $PrimaryAdapter = $Adapters |
            Where-Object { $_.IPv4Address.IPAddress -like $PrimarySubnet } |
            Select-Object -First 1
    }

    if (-not $PrimaryAdapter)
    {
        $PrimaryAdapter = $Adapters |
            Where-Object { $_.IPv4DefaultGateway } |
            Select-Object -First 1
    }

    $IPAddress   = ''
    $AddressType = ''

    if ($PrimaryAdapter)
    {
        $IPAddress = @($PrimaryAdapter.IPv4Address.IPAddress)[0]

        if ($PrimaryAdapter.NetIPv4Interface.Dhcp -eq 'Enabled')
        {
            $AddressType = 'DHCP'
        }
        else
        {
            $AddressType = 'Static'
        }
    }

    $Location = 'Office'

    if ($OnAirSubnet -and $IPAddress -like $OnAirSubnet)
    {
        $Location = 'On-Air'
    }

    $WheatstoneIP = ''

    if ($WheatstoneSubnet)
    {
        $WheatstoneAddress = $Adapters.IPv4Address.IPAddress |
            Where-Object { $_ -like $WheatstoneSubnet } |
            Select-Object -First 1

        if ($WheatstoneAddress)
        {
            $WheatstoneIP = $WheatstoneAddress
        }
    }

    [PSCustomObject]@{
        IPAddress    = $IPAddress
        AddressType  = $AddressType
        Location     = $Location
        WheatstoneIP = $WheatstoneIP
    }
}
