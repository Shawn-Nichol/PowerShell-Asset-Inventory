function New-StatusRecord
{
    <#
    .SYNOPSIS
        Creates a report row for a computer that could not be audited.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$ComputerName,

        [Parameter(Mandatory)]
        [string]$Notes
    )

    New-AuditRecord -Base (New-BaseRecord -ComputerName $ComputerName) -Notes $Notes
}
