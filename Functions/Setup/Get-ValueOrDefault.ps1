function Get-ValueOrDefault
{
    <#
    .SYNOPSIS
        Returns Value when it has content, otherwise Default.

    .DESCRIPTION
        Windows PowerShell 5.1 has no ?? operator. This helper keeps the one
        "use this, or fall back to that" decision in a single place.

    .EXAMPLE
        Get-ValueOrDefault -Value $Definition.ServiceType -Default 'Application'
    #>
    [CmdletBinding()]
    param
    (
        $Value,

        $Default
    )

    if ($Value) { return $Value }

    return $Default
}
