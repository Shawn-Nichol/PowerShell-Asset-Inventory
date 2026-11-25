function Get-TargetComputer
{
    <#
    .SYNOPSIS
        Returns the computers to audit.

    .DESCRIPTION
        Uses -ComputerName when given, otherwise the computer list file,
        otherwise just the local computer.
    #>
    [CmdletBinding()]
    param
    (
        [string[]]$ComputerName,

        [string]$ListPath
    )

    if ($ComputerName)
    {
        return $ComputerName | Sort-Object -Unique
    }

    if ($ListPath -and (Test-Path -Path $ListPath))
    {
        $Computers = Get-Content -Path $ListPath |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ -and $_ -notmatch '^#' } |
            Sort-Object -Unique

        Write-Verbose "Loaded $(@($Computers).Count) computers from $ListPath"
        return $Computers
    }

    Write-Verbose "No computer list found at $ListPath; auditing $env:COMPUTERNAME only."
    return $env:COMPUTERNAME
}
