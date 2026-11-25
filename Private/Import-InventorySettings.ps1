function Import-InventorySettings
{
    <#
    .SYNOPSIS
        Loads the application list and network settings into one hashtable.

    .DESCRIPTION
        Settings are PowerShell data files (.psd1), read with
        Import-PowerShellDataFile. Unlike a .ps1 config, a data file is never
        executed, so it cannot be used to run code.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$ApplicationsPath,

        [Parameter(Mandatory)]
        [string]$NetworkPath
    )

    if (-not (Test-Path -Path $ApplicationsPath))
    {
        throw "Application list not found: $ApplicationsPath"
    }

    $ApplicationData = Import-PowerShellDataFile -Path $ApplicationsPath
    $Applications    = @($ApplicationData.Applications)

    if ($Applications.Count -eq 0)
    {
        throw "No applications defined in $ApplicationsPath"
    }

    foreach ($Definition in $Applications)
    {
        if (-not $Definition.Name)
        {
            throw "Every application in $ApplicationsPath needs a Name."
        }
    }

    $Network = @{
        PrimarySubnet    = ''
        OnAirSubnet      = ''
        WheatstoneSubnet = ''
    }

    if (Test-Path -Path $NetworkPath)
    {
        $NetworkData = Import-PowerShellDataFile -Path $NetworkPath

        foreach ($Key in @($Network.Keys))
        {
            if ($NetworkData.ContainsKey($Key))
            {
                $Network[$Key] = [string]$NetworkData[$Key]
            }
        }
    }
    else
    {
        Write-Warning ("Network settings not found at $NetworkPath. " +
            'Location and Wheatstone columns will use defaults. ' +
            'Copy Config\Network.example.psd1 to Config\Network.psd1 to configure them.')
    }

    @{
        Applications = $Applications
        Network      = $Network
    }
}
