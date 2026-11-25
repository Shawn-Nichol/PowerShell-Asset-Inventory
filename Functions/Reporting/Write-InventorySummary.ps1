function Write-InventorySummary
{
    <#
    .SYNOPSIS
        Prints a short summary of the inventory run.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [object[]]$Records,

        [Parameter(Mandatory)]
        [int]$ComputerCount,

        [Parameter(Mandatory)]
        [string]$ReportPath
    )

    $ProblemPattern = '^(Offline|WinRM unavailable|Error:)'

    $ProblemComputers = @(
        $Records |
            Where-Object { $_.Notes -match $ProblemPattern } |
            ForEach-Object { $_.'Server / Workstation Name' } |
            Sort-Object -Unique
    )

    Write-Host ''
    Write-Host "Computers      : $ComputerCount" -ForegroundColor Cyan
    Write-Host "Need attention : $($ProblemComputers.Count) (see the Notes column)" -ForegroundColor Cyan
    Write-Host "Report rows    : $($Records.Count)" -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'CSV exported to:' -ForegroundColor Green
    Write-Host $ReportPath -ForegroundColor Cyan
}
