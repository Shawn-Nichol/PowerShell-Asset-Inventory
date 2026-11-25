function Test-WinRM
{
    param(
        [string]$ComputerName
    )

    try
    {
        Test-WSMan $ComputerName -ErrorAction Stop | Out-Null

        Write-Host "$ComputerName - WinRM OK" `
            -ForegroundColor Green

        return $true
    }
    catch
    {
        Write-Warning "$ComputerName - WinRM Not Responding"

        return $false
    }
}