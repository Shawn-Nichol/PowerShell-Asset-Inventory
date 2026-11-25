function Get-SystemInfo
{
    <#
    .SYNOPSIS
        Returns the operating system and hardware type of the local machine.
    #>
    [CmdletBinding()]
    param()

    $OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
    $ComputerSystem  = Get-CimInstance -ClassName Win32_ComputerSystem

    # Hyper-V reports the model "Virtual Machine"; VMware, Xen, QEMU and
    # VirtualBox identify themselves in the model or manufacturer.
    $IsVirtual =
        $ComputerSystem.Model -match 'Virtual|VMware' -or
        $ComputerSystem.Manufacturer -match 'VMware|Xen|QEMU|innotek'

    if ($IsVirtual)
    {
        $MachineType = 'VM'
    }
    else
    {
        $MachineType = '{0} {1}' -f $ComputerSystem.Manufacturer, $ComputerSystem.Model
    }

    [PSCustomObject]@{
        OS          = $OperatingSystem.Caption
        MachineType = $MachineType
    }
}
