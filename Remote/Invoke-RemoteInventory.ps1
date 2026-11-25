function Invoke-RemoteInventory
{
    <#
    .SYNOPSIS
        Audits the machine it runs on and returns one row per tracked application.

    .DESCRIPTION
        Runs on each target computer (sent there by Start-Inventory.ps1).
        Always returns at least one row, so a machine never silently drops
        out of the report: an error row if something fails, or a
        "No tracked applications found" row if nothing matched.

    .PARAMETER Settings
        Hashtable with Applications (array of definitions) and Network
        (PrimarySubnet, OnAirSubnet, WheatstoneSubnet).
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [hashtable]$Settings
    )

    $ErrorActionPreference = 'Stop'

    $Base = New-BaseRecord -ComputerName $env:COMPUTERNAME

    try
    {
        $Network = $Settings.Network
        $System  = Get-SystemInfo

        $NetworkInfo = Get-NetworkInfo `
            -PrimarySubnet $Network.PrimarySubnet `
            -OnAirSubnet $Network.OnAirSubnet `
            -WheatstoneSubnet $Network.WheatstoneSubnet

        $Base = New-BaseRecord `
            -ComputerName $env:COMPUTERNAME `
            -OS $System.OS `
            -PrimaryUser (Get-AutoLogonUser) `
            -MachineType $System.MachineType `
            -Location $NetworkInfo.Location `
            -AddressType $NetworkInfo.AddressType `
            -WheatstoneIP $NetworkInfo.WheatstoneIP

        $Processes     = @(Get-RunningProcess)
        $Burli         = Get-BurliInfo
        $InstalledApps = @(Get-InstalledApplication -Applications $Settings.Applications)

        $Records = foreach ($App in $InstalledApps)
        {
            $Definition = $App.Definition
            $IsBurli    = $Definition.Name -eq 'Burli'

            $ServiceType = 'Application'
            if ($Definition.ServiceType) { $ServiceType = $Definition.ServiceType }

            $Notes = ''
            if (-not $Definition.Functionality) { $Notes = 'Application definition required' }

            $LicenseType = ''
            $HaspID      = ''
            if ($IsBurli)
            {
                $LicenseType = $Burli.LicenseType
                $HaspID      = $Burli.HaspID
            }

            New-AuditRecord `
                -Base $Base `
                -ApplicationName $App.DisplayName `
                -Functionality $Definition.Functionality `
                -UserType $Definition.UserType `
                -ServiceType $ServiceType `
                -Executable (Get-ExecutableName -Application $App -RunningProcesses $Processes) `
                -Version $App.DisplayVersion `
                -LicenseType $LicenseType `
                -HaspID $HaspID `
                -Notes $Notes
        }

        $Records = @($Records)

        # Burli is sometimes present in the registry without an entry in
        # the installed programs list. Report it so it is not missed.
        $BurliReported = $InstalledApps | Where-Object { $_.Definition.Name -eq 'Burli' }

        if ($Burli.Installed -and -not $BurliReported)
        {
            $BurliDefinition = $Settings.Applications |
                Where-Object { $_.Name -eq 'Burli' } |
                Select-Object -First 1

            $Records += New-AuditRecord `
                -Base $Base `
                -ApplicationName 'Burli' `
                -Functionality $BurliDefinition.Functionality `
                -UserType $BurliDefinition.UserType `
                -ServiceType 'Application' `
                -Executable $BurliDefinition.Executable `
                -LicenseType $Burli.LicenseType `
                -HaspID $Burli.HaspID `
                -Notes 'Found in Burli registry key; not in installed programs'
        }

        if ($Records.Count -eq 0)
        {
            $Records = @(New-AuditRecord -Base $Base -Notes 'No tracked applications found')
        }

        return $Records
    }
    catch
    {
        return New-AuditRecord -Base $Base -Notes "Error: $($_.Exception.Message)"
    }
}
