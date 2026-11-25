function Get-RunningProcesses
{
    Get-Process |
        Where-Object {
            $_.Path
        } |
        Select-Object `
            ProcessName,
            Path
}