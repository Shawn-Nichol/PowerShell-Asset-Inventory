function Export-InventoryReport
{
    <#
    .SYNOPSIS
        Writes the report rows to a timestamped CSV and returns its path.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [object[]]$Records,

        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    if (-not (Test-Path -Path $OutputPath))
    {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }

    $FileName = 'AssetInventory-{0}.csv' -f (Get-Date -Format 'yyyy-MM-dd_HHmm')
    $FilePath = Join-Path -Path $OutputPath -ChildPath $FileName

    # Remoting adds PSComputerName, RunspaceId and PSShowComputerName to
    # every returned object; they are not report columns.
    $Records |
        Select-Object -Property * -ExcludeProperty PSComputerName, RunspaceId, PSShowComputerName |
        Export-Csv -Path $FilePath -NoTypeInformation

    return $FilePath
}
