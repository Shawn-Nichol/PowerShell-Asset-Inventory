function Get-RunningProcess
{
    <#
    .SYNOPSIS
        Returns the name and full path of running processes.
    #>
    [CmdletBinding()]
    param()

    Get-Process |
        Where-Object { $_.Path } |
        Select-Object -Property Name, Path
}
