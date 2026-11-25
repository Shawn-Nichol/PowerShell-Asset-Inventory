function Get-ComputerInventory
{
    <#
    .SYNOPSIS
        Audits the computer it runs on and returns one row per tracked application.

    .DESCRIPTION
        This is what runs on each target computer. It always returns at least
        one row: an error row if something fails, or a "No tracked
        applications found" row if nothing matched.

    .PARAMETER Settings
        Output of Import-InventorySettings: Applications and Network.
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
        $Base          = Get-MachineInfo -Network $Settings.Network
        $Processes     = @(Get-RunningProcess)
        $InstalledApps = @(Get-InstalledApplication -Applications $Settings.Applications)

        # Extra details for specific applications, keyed by definition Name.
        $AppDetails = @{
            'Burli'      = Get-BurliInfo
            'TeamViewer' = Get-TeamViewerInfo
        }

        $Records = @(
            $InstalledApps | ForEach-Object {
                New-ApplicationRecord -Base $Base -Application $_ -AppDetails $AppDetails -RunningProcesses $Processes
            }

            New-BurliRegistryRecord -Base $Base -Burli $AppDetails.Burli -InstalledApps $InstalledApps -Applications $Settings.Applications
        )

        if ($Records.Count -eq 0) { return New-AuditRecord -Base $Base -Notes 'No tracked applications found' }

        return $Records
    }
    catch
    {
        return New-AuditRecord -Base $Base -Notes "Error: $($_.Exception.Message)"
    }
}
