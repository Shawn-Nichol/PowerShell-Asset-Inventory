function Get-NetworkInfo
{
    $Adapters =
        Get-NetIPConfiguration |
        Where-Object {
            $_.IPv4Address
        }

    $NetworkNIC =
        $Adapters |
        Where-Object {
            $_.IPv4Address.IPAddress -like "172.*"
        } |
        Select-Object -First 1

    $WheatstoneNIC =
        $Adapters |
        Where-Object {
            $_.IPv4Address.IPAddress -like "192.168.*"
        } |
        Select-Object -First 1

    if ($NetworkNIC)
    {
        $IPAddress =
            $NetworkNIC.IPv4Address.IPAddress
    }
    else
    {
        $IPAddress = ""
    }

    if ($IPAddress -like "172.24.6.*")
    {
        $OnAirOffice = "On-Air"
    }
    else
    {
        $OnAirOffice = "Office"
    }

    $WheatstoneIP =
        if ($WheatstoneNIC)
        {
            $WheatstoneNIC.IPv4Address.IPAddress
        }
        else
        {
            ""
        }

    [PSCustomObject]@{

        IPAddress    = $IPAddress

        AddressType  = $IPAddress

        OnAirOffice  = $OnAirOffice

        WheatstoneIP = $WheatstoneIP
    }

}
