function New-ApplicationRecord
{
    <#
    .SYNOPSIS
        Creates the report row for one installed application.

    .PARAMETER AppDetails
        Extra details for specific applications, keyed by definition Name,
        for example @{ Burli = <license info>; TeamViewer = <ID> }.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [hashtable]$Base,

        [Parameter(Mandatory)]
        $Application,

        [hashtable]$AppDetails = @{},

        [object[]]$RunningProcesses = @()
    )

    $Definition = $Application.Definition

    # Only some applications have extra details (Burli licensing, TeamViewer ID).
    # Looking the name up returns nothing for every other application, so
    # those columns stay empty without needing an if statement.
    $Details = $AppDetails[$Definition.Name]

    New-AuditRecord `
        -Base $Base `
        -ApplicationName $Application.DisplayName `
        -Functionality $Definition.Functionality `
        -UserType $Definition.UserType `
        -ServiceType $Definition.ServiceType `
        -Executable (Get-ExecutableName -Application $Application -RunningProcesses $RunningProcesses) `
        -Version $Application.DisplayVersion `
        -LicenseType $Details.LicenseType `
        -HaspID $Details.HaspID `
        -TeamViewerID $Details.TeamViewerID `
        -Notes $Definition.Notes
}
