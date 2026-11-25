function Import-InventorySettings
{
    <#
    .SYNOPSIS
        Loads the public application list and the internal Local settings
        into one hashtable.

    .DESCRIPTION
        Two files are read:
          Config\Applications.psd1  public application list, committed
          Local\Settings.psd1       internal settings, git-ignored:
                                      ComputerList  computer list file name
                                      Network       subnets
                                      Applications  private applications

        Private applications are checked before the public list, so they
        take priority. The computer list name is resolved relative to the
        Local folder unless it is a full path.

        Settings are PowerShell data files (.psd1), read with
        Import-PowerShellDataFile. Unlike a .ps1 config, a data file is never
        executed, so it cannot be used to run code.

        Every application definition is filled in with defaults here, so the
        rest of the code can use the values directly without checking them.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$ApplicationsPath,

        [Parameter(Mandatory)]
        [string]$LocalSettingsPath
    )

    if (-not (Test-Path -Path $LocalSettingsPath))
    {
        Write-Warning ("Local settings not found at $LocalSettingsPath. " +
            'Copy Config\Settings.example.psd1 to Local\Settings.psd1 to set your ' +
            'computer list, subnets and private applications.')
    }

    # Get-Item returns nothing for a missing file, so the import is skipped
    # and empty defaults are used.
    $ImportedLocal = Get-Item -Path $LocalSettingsPath -ErrorAction SilentlyContinue |
        ForEach-Object { Import-PowerShellDataFile -Path $_.FullName }

    $LocalSettings = Get-ValueOrDefault -Value $ImportedLocal -Default @{}
    $LocalFolder   = Split-Path -Path $LocalSettingsPath -Parent

    $PublicApplications = (Import-PowerShellDataFile -Path $ApplicationsPath).Applications
    $AllDefinitions     = @(@($LocalSettings.Applications) + @($PublicApplications) | Where-Object { $_ })

    Write-Verbose "Loaded $(@($LocalSettings.Applications | Where-Object { $_ }).Count) private and $(@($PublicApplications).Count) public application definitions"

    $Unnamed = @($AllDefinitions | Where-Object { -not $_.Name })

    if ($Unnamed.Count -gt 0) { throw 'Every application definition needs a Name.' }

    $Applications = foreach ($Definition in $AllDefinitions)
    {
        $IsDescribed = [bool]$Definition.Functionality
        $DefinitionNotes = @{ $true = ''; $false = 'Application definition required' }

        @{
            Name          = [string]$Definition.Name
            Match         = @(Get-ValueOrDefault -Value $Definition.Match -Default "*$($Definition.Name)*")
            Functionality = [string]$Definition.Functionality
            UserType      = [string]$Definition.UserType
            ServiceType   = [string](Get-ValueOrDefault -Value $Definition.ServiceType -Default 'Application')
            Executable    = [string]$Definition.Executable
            Notes         = $DefinitionNotes[$IsDescribed]
        }
    }

    # Combine keeps a full path as-is and puts a plain file name in the Local folder.
    $ComputerList = Get-ValueOrDefault -Value $LocalSettings.ComputerList -Default 'Computers.txt'

    @{
        Applications     = @($Applications)
        ComputerListPath = [System.IO.Path]::Combine($LocalFolder, $ComputerList)
        Network          = @{
            PrimarySubnet    = [string]$LocalSettings.Network.PrimarySubnet
            OnAirSubnet      = [string]$LocalSettings.Network.OnAirSubnet
            WheatstoneSubnet = [string]$LocalSettings.Network.WheatstoneSubnet
        }
    }
}
