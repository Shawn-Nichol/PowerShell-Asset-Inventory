function Test-WinRM
{
    <#
    .SYNOPSIS
        Returns $true when the computer answers WinRM (PowerShell remoting).
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$ComputerName
    )

    try
    {
        Test-WSMan -ComputerName $ComputerName -ErrorAction Stop | Out-Null
        Write-Verbose "$ComputerName - WinRM OK"
        return $true
    }
    catch
    {
        Write-Verbose "$ComputerName - WinRM not responding"
        return $false
    }
}
