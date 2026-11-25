function Repair-WinRM
{
    param(
        [string]$ComputerName
    )

    try
    {
        Write-Host "$ComputerName - Attempting WinRM Repair..." `
            -ForegroundColor Yellow

        psexec "\\$ComputerName" -s powershell.exe -Command "

            Enable-PSRemoting -Force

            Set-Service WinRM -StartupType Automatic

            Start-Service WinRM

        " *> $null

        Start-Sleep -Seconds 5

        Test-WSMan $ComputerName -ErrorAction Stop | Out-Null

        Write-Host "$ComputerName - WinRM Repaired" `
            -ForegroundColor Green

        return $true
    }
    catch
    {
        Write-Warning "$ComputerName - WinRM Repair Failed"

        return $false
    }
}