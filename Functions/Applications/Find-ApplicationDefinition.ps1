function Find-ApplicationDefinition
{
    <#
    .SYNOPSIS
        Returns the first application definition with a Match pattern that
        fits the installed program name, or nothing when none match.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$DisplayName,

        [Parameter(Mandatory)]
        [object[]]$Applications
    )

    $Applications |
        Where-Object { $_.Match | Where-Object { $DisplayName -like $_ } } |
        Select-Object -First 1
}
