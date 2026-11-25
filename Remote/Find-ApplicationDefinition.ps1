function Find-ApplicationDefinition
{
    <#
    .SYNOPSIS
        Returns the first application definition whose Match pattern(s)
        match the installed program name, or $null when none match.
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

    foreach ($Definition in $Applications)
    {
        if ($Definition.Match)
        {
            $Patterns = @($Definition.Match)
        }
        else
        {
            $Patterns = @("*$($Definition.Name)*")
        }

        foreach ($Pattern in $Patterns)
        {
            if ($DisplayName -like $Pattern)
            {
                return $Definition
            }
        }
    }

    return $null
}
