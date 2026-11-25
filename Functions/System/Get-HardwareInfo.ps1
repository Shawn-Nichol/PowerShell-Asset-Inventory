function Get-HardwareInfo
{
    <#
    .SYNOPSIS
        Returns the CPU, installed RAM, and the size and free space of the C: drive.
    #>
    [CmdletBinding()]
    param()

    $Processor      = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
    $ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    $SystemDrive    = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"

    [PSCustomObject]@{
        CPU        = "$($Processor.Name)".Trim() -replace '\s+', ' '
        RamGB      = [math]::Round($ComputerSystem.TotalPhysicalMemory / 1GB, 1)
        DiskSizeGB = [math]::Round($SystemDrive.Size / 1GB, 1)
        DiskFreeGB = [math]::Round($SystemDrive.FreeSpace / 1GB, 1)
    }
}
