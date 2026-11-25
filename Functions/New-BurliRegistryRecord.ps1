function New-BurliRegistryRecord
{
    <#
    .SYNOPSIS
        Creates a Burli row when Burli is in the registry but missing from
        the installed programs list. Returns nothing otherwise.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [hashtable]$Base,

        $Burli,

        [object[]]$InstalledApps = @(),

        [Parameter(Mandatory)]
        [object[]]$Applications
    )

    $AlreadyListed = $InstalledApps | Where-Object { $_.Definition.Name -eq 'Burli' }

    if (-not $Burli.Installed -or $AlreadyListed) { return }

    $Definition = $Applications | Where-Object { $_.Name -eq 'Burli' } | Select-Object -First 1

    New-AuditRecord `
        -Base $Base `
        -ApplicationName 'Burli' `
        -Functionality $Definition.Functionality `
        -UserType $Definition.UserType `
        -ServiceType $Definition.ServiceType `
        -Executable $Definition.Executable `
        -LicenseType $Burli.LicenseType `
        -HaspID $Burli.HaspID `
        -Notes 'Found in Burli registry key; not in installed programs'
}
