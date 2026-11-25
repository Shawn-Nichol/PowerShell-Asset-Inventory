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

    # -Force returns the folder if it already exists, so no check is needed.
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

    $FileName = 'AssetInventory-{0}.csv' -f (Get-Date -Format 'yyyy-MM-dd_HHmm')
    $FilePath = Join-Path -Path $OutputPath -ChildPath $FileName

    # Remoting adds PSComputerName, RunspaceId and PSShowComputerName to
    # every returned object; they are not report columns.
    # Rows are sorted by computer, then application, so each computer's
    # applications are grouped together.
    $Records |
        Sort-Object -Property 'Server / Workstation Name', 'Application Name' |
        Select-Object -Property * -ExcludeProperty PSComputerName, RunspaceId, PSShowComputerName |
        Export-Csv -Path $FilePath -NoTypeInformation

    $FilePath
}
