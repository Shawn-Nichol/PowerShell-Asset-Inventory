function Get-ApplicationDefinition
{
    param
    (
        [string]$ApplicationName,

        [hashtable]$ApplicationDefinitions
    )

    foreach ($Definition in $ApplicationDefinitions.Keys)
    {
        if ($ApplicationName -like "*$Definition*")
        {
            return $ApplicationDefinitions[$Definition]
        }
    }

    return $null
}