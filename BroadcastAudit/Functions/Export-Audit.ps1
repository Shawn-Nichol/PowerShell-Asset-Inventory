function Export-Audit
{
    param(
        $Results
    )

    $Date = Get-Date -Format "yyyy-MM-dd_HHmm"

    $ExportPath = Join-Path `
        $PSScriptRoot `
        "..\Output\ESI-Audit-$Date.csv"

    $Results |
    Select-Object `
        "Application Name",
        "Functionality",
        "End User / Server / Service",
        "Service / App",
        "Executable / startup",
        "Version",
        "Network HASP, Dedicated HASP, by File (codes)",
        "Hasp ID",
        "Server / Workstation Name",
        "OS",
        "Primary User / Service Account Name",
        "VM / BM / HW",
        "On-Air or Office",
        "Static IP or DHCP",
        "Wheatstone",
        "Notes" |
    Export-Csv `
        -Path $ExportPath `
        -NoTypeInformation

    Write-Host ""
    Write-Host "CSV Exported To:" -ForegroundColor Green
    Write-Host $ExportPath -ForegroundColor Cyan
}