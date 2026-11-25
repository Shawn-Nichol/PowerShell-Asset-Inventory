function Get-TargetComputer
{
    <#
    .SYNOPSIS
        Returns the computers to audit.

    .DESCRIPTION
        Uses -ComputerName when given, otherwise the computer list file,
        otherwise just this computer.
    #>
    [CmdletBinding()]
    param
    (
        [string[]]$ComputerName,

        [string]$ListPath
    )

    $FromFile = Get-Content -Path $ListPath -ErrorAction SilentlyContinue |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and $_ -notmatch '^#' }

    $FromFileOrLocal = Get-ValueOrDefault -Value $FromFile -Default $env:COMPUTERNAME

    Get-ValueOrDefault -Value $ComputerName -Default $FromFileOrLocal |
        Sort-Object -Unique
}
