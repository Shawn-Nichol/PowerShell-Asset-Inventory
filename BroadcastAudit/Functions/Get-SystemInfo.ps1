function Get-SystemInfo
{
    $OS = Get-CimInstance Win32_OperatingSystem

    $CS = Get-CimInstance Win32_ComputerSystem

    $IsVM =
        $CS.Model -match 'Virtual|VMware|Hyper-V' -or
        $CS.Manufacturer -match 'VMware|Microsoft Corporation'

    [PSCustomObject]@{

        OS = $OS.Caption

        Manufacturer = $CS.Manufacturer

        Model = $CS.Model

        MachineType =
            if ($IsVM)
            {
                'VM'
            }
            else
            {
                "$($CS.Manufacturer) $($CS.Model)"
            }
    }
}