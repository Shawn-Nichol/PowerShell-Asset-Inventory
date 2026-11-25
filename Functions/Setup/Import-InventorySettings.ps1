function Import-InventorySettings
{
    <#
    .SYNOPSIS
        Loads the application lists and network settings into one hashtable.

    .DESCRIPTION
        Settings are PowerShell data files (.psd1), read with
        Import-PowerShellDataFile. Unlike a .ps1 config, a data file is never
        executed, so it cannot be used to run code.

        Applications come from two files:
          Applications.psd1        public list, committed to the repository
          Applications.local.psd1  private list, git-ignored (optional)
        Local entries are checked first, so they take priority. Use the local
        file for anything that should not be published, such as security tools.

        Every application definition is filled in with defaults here, so the
        rest of the code can use the values directly without checking them.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$ApplicationsPath,

        [Parameter(Mandatory)]
        [string]$LocalApplicationsPath,

        [Parameter(Mandatory)]
        [string]$NetworkPath
    )

    $PublicApplications = (Import-PowerShellDataFile -Path $ApplicationsPath).Applications

    # Get-Item returns nothing when the local file does not exist, so the
    # import is skipped and only the public list is used.
    $LocalApplications = Get-Item -Path $LocalApplicationsPath -ErrorAction SilentlyContinue |
        ForEach-Object { (Import-PowerShellDataFile -Path $_.FullName).Applications }

    $AllDefinitions = @(@($LocalApplications) + @($PublicApplications) | Where-Object { $_ })

    Write-Verbose "Loaded $(@($LocalApplications | Where-Object { $_ }).Count) local and $(@($PublicApplications).Count) public application definitions"

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

    if (-not (Test-Path -Path $NetworkPath))
    {
        Write-Warning ("Network settings not found at $NetworkPath. " +
            'Location and Wheatstone columns will use defaults. ' +
            'Copy Config\Network.example.psd1 to Config\Network.psd1 to configure them.')
    }

    # Get-Item returns nothing for a missing file, so the import is skipped
    # and the empty default is used.
    $ImportedNetwork = Get-Item -Path $NetworkPath -ErrorAction SilentlyContinue |
        ForEach-Object { Import-PowerShellDataFile -Path $_.FullName }

    $NetworkData = Get-ValueOrDefault -Value $ImportedNetwork -Default @{}

    @{
        Applications = @($Applications)
        Network      = @{
            PrimarySubnet    = [string]$NetworkData.PrimarySubnet
            OnAirSubnet      = [string]$NetworkData.OnAirSubnet
            WheatstoneSubnet = [string]$NetworkData.WheatstoneSubnet
        }
    }
}
