function Get-SystemInfo
{
    <#
    .SYNOPSIS
        Returns the operating system, hardware type and time zone of this computer.
    #>
    [CmdletBinding()]
    param()

    $OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
    $ComputerSystem  = Get-CimInstance -ClassName Win32_ComputerSystem
    $TimeZone        = Get-CimInstance -ClassName Win32_TimeZone

    # Hyper-V reports the model "Virtual Machine"; VMware, Xen, QEMU and
    # VirtualBox identify themselves in the model or manufacturer.
    $IsVirtual = [bool](
        $ComputerSystem.Model -match 'Virtual|VMware' -or
        $ComputerSystem.Manufacturer -match 'VMware|Xen|QEMU|innotek'
    )

    $MachineType = @{
        $true  = 'VM'
        $false = '{0} {1}' -f $ComputerSystem.Manufacturer, $ComputerSystem.Model
    }

    [PSCustomObject]@{
        OS          = $OperatingSystem.Caption
        MachineType = $MachineType[$IsVirtual]
        TimeZone    = [string]$TimeZone.Caption
    }
}
