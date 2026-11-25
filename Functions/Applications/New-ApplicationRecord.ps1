function New-ApplicationRecord
{
    <#
    .SYNOPSIS
        Creates the report row for one installed application.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [hashtable]$Base,

        [Parameter(Mandatory)]
        $Application,

        $Burli,

        [object[]]$RunningProcesses = @()
    )

    $Definition = $Application.Definition

    # License details are only known for Burli. Looking the name up in a
    # table returns nothing for every other application, so their license
    # columns stay empty without needing an if statement.
    $LicenseByApplication = @{ 'Burli' = $Burli }
    $License = $LicenseByApplication[$Definition.Name]

    New-AuditRecord `
        -Base $Base `
        -ApplicationName $Application.DisplayName `
        -Functionality $Definition.Functionality `
        -UserType $Definition.UserType `
        -ServiceType $Definition.ServiceType `
        -Executable (Get-ExecutableName -Application $Application -RunningProcesses $RunningProcesses) `
        -Version $Application.DisplayVersion `
        -LicenseType $License.LicenseType `
        -HaspID $License.HaspID `
        -Notes $Definition.Notes
}
