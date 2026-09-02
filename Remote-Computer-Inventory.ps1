# =====================================================
# Broadcast Audit Script
# One Row Per Application
# =====================================================

# =====================================================
# COMPUTER LIST
# =====================================================

$ComputerList = Join-Path `
    $env:USERPROFILE `
    "Documents\BroadcastComputers.txt"

if (Test-Path $ComputerList)
{
    # Normal mode
    # Load computers from text file

    $Computers = Get-Content $ComputerList |
        Where-Object {
            $_.Trim() -ne "" -and
            $_ -notmatch '^#'
        }

    Write-Host ""
    Write-Host "Loaded $($Computers.Count) computers from file." -ForegroundColor Cyan
}
else
{
    # Standalone mode
    # Audit only the computer running the script

    $Computers = @($env:COMPUTERNAME)

    Write-Host ""
    Write-Host "Computer list not found." -ForegroundColor Yellow
    Write-Host "Running local audit on: $env:COMPUTERNAME" -ForegroundColor Cyan
}

$Results = foreach ($Computer in $Computers)
{

    # =====================================================
    # OFFLINE CHECK
    # =====================================================

    if (-not (Test-Connection $Computer -Count 1 -Quiet))
    {
        Write-Warning "$Computer - Offline"

        [PSCustomObject]@{

            "Application Name" = ""

            "Functionality" = ""

            "End User / Server / Service" = ""

            "Service / App" = ""

            "Executable / startup" = ""

            "Version" = ""

            "Network HASP, Dedicated HASP, by File (codes)" = ""

            "Hasp ID" = ""

            "Server / Workstation Name" = $Computer

            "OS" = ""

            "Primary User / Service Account Name" = ""

            "VM / BM / HW" = ""

            "On-Air or Office" = ""

            "Static IP or DHCP" = ""

            "Wheatstone" = ""

            "Notes" = "Offline"
        }

        continue
    }

    # =====================================================
    # WINRM VALIDATION
    # =====================================================

    $WinRM_OK = $false

    try
    {
        Test-WSMan $Computer -ErrorAction Stop | Out-Null

        $WinRM_OK = $true

        Write-Host "$Computer - WinRM OK" -ForegroundColor Green
    }
    catch
    {
        Write-Warning "$Computer - WinRM Not Responding"

        try
        {
            Write-Host "$Computer - Attempting WinRM Repair..." -ForegroundColor Yellow

            psexec "\\$Computer" -s powershell.exe -Command "

                Enable-PSRemoting -Force

                Set-Service WinRM -StartupType Automatic

                Start-Service WinRM

            " *> $null

            Start-Sleep -Seconds 5

            Test-WSMan $Computer -ErrorAction Stop | Out-Null

            $WinRM_OK = $true

            Write-Host "$Computer - WinRM Repaired" -ForegroundColor Green
        }
        catch
        {
            Write-Warning "$Computer - WinRM Repair Failed"
        }
    }

     
     Invoke-Command -ComputerName $Computer -ScriptBlock {

        # =====================================================
        # ERROR HANDLING
        # =====================================================

        $ErrorActionPreference = "Stop"

        # =====================================================
        # APPLICATION DEFINITIONS
        # =====================================================

        $ApplicationDefinitions = @{

            "iMediaLogger" = @{
                Functionality = "Audio Logger"
                UserType      = "Service - Content Capture"
                ServiceType   = "Application"
            }

            "Burli" = @{
                Functionality = "News Content Software"
                UserType      = "End User"
                ServiceType   = "Application"
            }

            "CSRDS" = @{
                Functionality = "Metadata Transfer"
                UserType      = "Service - Content Transfer"
                ServiceType   = "Application"
            }

            "Dav" = @{
                Functionality = "Site Monitor Interface"
                UserType      = "End User"
                ServiceType   = "Application"
            }

            "GV Stratus" = @{
                Functionality = "News Production System"
                UserType = "End User"
                ServiceType = "Application"
                Executable = "STRATUS.exe"
            }

            "OpenMedia" = @{
            Functionality = "News Production System"
            UserType = "End User"
            ServiceType = "Application"
            Executable = "OpenMedia.exe"
            }

            "VoxPro" = @{
                Functionality = "Audio Editor - Phone Callers"
                UserType      = "End User"
                ServiceType   = "Application"
            }


        }

        # =====================================================
        # MACHINE INFORMATION
        # =====================================================

        $OS = Get-CimInstance Win32_OperatingSystem

        $CS = Get-CimInstance Win32_ComputerSystem

        if (
            $CS.Model -match "Virtual" -or
            $CS.Model -match "VMware" -or
            $CS.Manufacturer -match "VMware" -or
            $CS.Manufacturer -match "Microsoft Corporation"
        ) {
            $MachineType = "VM"
        }
        else {

            # Physical machine
            $MachineType = "$($CS.Manufacturer) $($CS.Model)"
        }

        # =====================================================
        # NETWORK INFORMATION
        # =====================================================

        $Adapters = Get-NetIPConfiguration |
            Where-Object { $_.IPv4Address }

        $NetworkNIC = $Adapters |
            Where-Object {
                $_.IPv4Address.IPAddress -like "172.*"
            } |
            Select-Object -First 1

        $WheatstoneNIC = $Adapters |
            Where-Object {
                $_.IPv4Address.IPAddress -like "192.168.*"
            } |
            Select-Object -First 1

        if ($NetworkNIC.IPv4Address.IPAddress -like "172.24.6.*")
        {
            $OnAirOffice = "On-Air"
            $AddressType = $NetworkNIC.IPv4Address.IPAddress
        }
        else
        {
            $OnAirOffice = "Office"
            $AddressType = $NetworkNIC.IPv4Address.IPAddress
        }

        # =====================================================
        # USER INFORMATION
        # =====================================================

        $WinLogon = Get-ItemProperty `
            "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" `
            -ErrorAction SilentlyContinue

        $AutoLogonUser = $WinLogon.DefaultUserName

        # =====================================================
        # BURLI DISCOVERY
        # =====================================================

        $BurliInstalled = Test-Path `
            "HKLM:\Software\WOW6432Node\Burli\RadioStar"

        $BurliHaspID = ""

        if ($BurliInstalled)
        {
            $BurliInternet = Get-ItemProperty `
                "HKLM:\Software\WOW6432Node\Burli\RadioStar\Internet" `
                -ErrorAction SilentlyContinue

            $BurliHaspID = $BurliInternet."Unique ID"
        }


        # =====================================================
        # HASP DISCOVERY
        # =====================================================

        $HaspDevices = Get-CimInstance Win32_PnPEntity |
        Where-Object {
            $_.Name -match "HASP|Sentinel"
        }

        $BurliLicenseType = "Network HASP"

        if ($HaspDevices)
        {
            $BurliLicenseType = "Dedicated HASP"
        }



        # =====================================================
        # SENTINEL HASP DISCOVERY
        # =====================================================

        $SentinelHaspID = ""
        $SentinelLicenseType = ""

        try
        {
            $Content = (
                Invoke-WebRequest `
                    "http://localhost:1947/_int_/tab_dev.html" `
                    -UseBasicParsing
            ).Content

            $Blocks = $Content -split '\},'

            # Prefer local key first

            $LocalKey = $Blocks |
                Where-Object {
                    $_ -match '"isloc":"1"' -and
                    $_ -match '"typ":"Sentinel HL'
                } |
                Select-Object -First 1

            if ($LocalKey)
            {
                if ($LocalKey -match '"haspid":"(\d+)"')
                {
                    $SentinelHaspID = $Matches[1]
                }

                $SentinelLicenseType = "Dedicated HASP"
            }
            else
            {
                # Fall back to network key

                $NetworkKey = $Blocks |
                    Where-Object {
                        $_ -match '"isloc":"0"' -and
                        $_ -match '"haspid":"\d+"'
                    } |
                    Select-Object -First 1

                if ($NetworkKey)
                {
                    if ($NetworkKey -match '"haspid":"(\d+)"')
                    {
                        $SentinelHaspID = $Matches[1]
                    }

                    $SentinelLicenseType = "Network HASP"
                }
            }
        }
        catch
        {
        }

        # =====================================================
        # CREATE BURLI ROW
        # =====================================================

        if ($BurliInstalled)
        {
            [PSCustomObject]@{

                "Application Name" = "Burli"

                "Functionality" = "News Content Software"

                "End User / Server / Service" = "End User"

                "Service / App" = "Application"

                "Executable / startup" = "Burli.exe"

                "Version" = "246c-HL"

                "Network HASP, Dedicated HASP, by File (codes)" = $BurliLicenseType

                "Hasp ID" = [string]$BurliHaspID

                "Server / Workstation Name" = $env:COMPUTERNAME

                "OS" = $OS.Caption

                "Primary User / Service Account Name" = $AutoLogonUser

                "VM / BM / HW" = $MachineType

                "On-Air or Office" = $OnAirOffice

                "Static IP or DHCP" = $AddressType

                "Wheatstone" = if ($WheatstoneNIC)
                {
                    $WheatstoneNIC.IPv4Address.IPAddress
                }
                else
                {
                    ""
                }

                "Notes" = "Discovered from Burli Registry"
            }
        }


        # =====================================================
        # APPLICATION DISCOVERY
        # =====================================================

        $BroadcastApps = @(
            "WideOrbit",
            "Burli",
            "Dav",
            "iMedia",
            "Logger",
            "DJB",
            "CSRDS",
            "Arctic Palm",
            "Nautel",
            "Sage",
            "VMix",
            "VoxPro",
            "ProTools",
            "LeanEncoder",
            "DreamEncoder",
            "GV Stratus",
            "Stratus",
            "OpenMedia"
        )

        $InstalledApps = Get-ItemProperty `
            HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,
            HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
            -ErrorAction SilentlyContinue |

            Where-Object {

                $DisplayName = [string]$_.DisplayName

                foreach ($App in $BroadcastApps)
                {
                    if ($DisplayName -like "*$App*")
                    {
                        return $true
                    }
                }

                $false
            }

        # =====================================================
        # PROCESS DISCOVERY
        # =====================================================

        $RunningProcesses = Get-Process |
            Where-Object { $_.Path } |
            Select-Object ProcessName, Path

        # =====================================================
        # BUILD ONE ROW PER APPLICATION
        # =====================================================

        foreach ($Application in $InstalledApps)
        {
            # Attempt to match application definition

            $AppInfo = $null

            foreach ($Definition in $ApplicationDefinitions.Keys)
            {
                if ($Application.DisplayName -like "*$Definition*")
                {
                    $AppInfo = $ApplicationDefinitions[$Definition]
                    break
                }
            }

            # Attempt to locate executable from running processes

            # =====================================================
            # EXECUTABLE DISCOVERY
            # =====================================================

            $Executable = ""

            # Running process match first

            foreach ($Process in $RunningProcesses)
            {
                if ($Process.Path -like "*$($Application.DisplayName.Split(' ')[0])*")
                {
                    $Executable = Split-Path $Process.Path -Leaf
                    break
                }
            }

            # Fall back to install location
 
            if (-not $Executable -and $Application.InstallLocation)
            {
                $ExeFiles = Get-ChildItem `
                    -Path $Application.InstallLocation `
                    -Filter *.exe `
                    -ErrorAction SilentlyContinue |
    
                Where-Object {
                    $_.Name -notmatch "Uninstall"
                }
               
            $Executable = $ExeFiles |
            Select-Object -ExpandProperty Name -First 1
            }
            

            # Known Application

            if ($AppInfo)
            {
                [PSCustomObject]@{

                    "Application Name" = $Application.DisplayName

                    "Functionality" = $AppInfo.Functionality

                    "End User / Server / Service" = $AppInfo.UserType

                    "Service / App" = $AppInfo.ServiceType

                    "Executable / startup" = if ($Executable)
                    {
                        $Executable
                    }
                    else
                    {
                        $AppInfo.Executable
                    }

                    "Version" = $Application.DisplayVersion
                    "Network HASP, Dedicated HASP, by File (codes)" = if (
                        $Application.DisplayName -match "VoxPro"
                    )
                    {
                        $SentinelLicenseType
                    }
                    else
                    {
                        ""
                    }

                    "Hasp ID" = if (
                        $Application.DisplayName -match "VoxPro"
                    )
                    {
                        [string]$SentinelHaspID
                    }
                    else
                    {
                        ""
                    }

                    "Server / Workstation Name" = $env:COMPUTERNAME

                    "OS" = $OS.Caption

                    "Primary User / Service Account Name" = $AutoLogonUser

                    "VM / BM / HW" = $MachineType

                    "On-Air or Office" = $OnAirOffice

                    "Static IP or DHCP" = $AddressType

                    "Wheatstone" = if ($WheatstoneNIC)
                    {
                        $WheatstoneNIC.IPv4Address.IPAddress
                    }
                    else
                    {
                        ""
                    }

                    "Notes" = ""
                }
            }

            # Unknown Application

            else
            {
                [PSCustomObject]@{

                    "Application Name" = $Application.DisplayName

                    "Functionality" = ""

                    "End User / Server / Service" = ""

                    "Service / App" = "Application"

                    "Executable / startup" = $Executable

                    "Version" = $Application.DisplayVersion

                    "Network HASP, Dedicated HASP, by File (codes)" = ""

                    "Hasp ID" = ""

                    "Server / Workstation Name" = $env:COMPUTERNAME

                    "OS" = $OS.Caption

                    "Primary User / Service Account Name" = $AutoLogonUser

                    "VM / BM / HW" = $MachineType

                    "On-Air or Office" = $OnAirOffice

                    "Static IP or DHCP" = $AddressType

                    "Wheatstone" = if ($WheatstoneNIC)
                    {
                        $WheatstoneNIC.IPv4Address.IPAddress
                    }
                    else
                    {
                        ""
                    }

                    "Notes" = "Application definition required"
                }
            }
        }
    }
}

# =====================================================
# EXPORT CSV
# =====================================================

$Date = Get-Date -Format "yyyy-MM-dd_HHmm"

$ExportPath = Join-Path `
    $env:USERPROFILE `
    "Documents\ESI-Audit-$Date.csv"

$Results |
Select-Object `
    "Application Name",
    "Functionality",
    "End User / Server / Service",
    "Service / App",
    "Executable / startup",
    "Version",
    "Network HASP, Dedicated HASP, by File (codes)",
    "Hasp ID",
    "Server / Workstation Name",
    "OS",
    "Primary User / Service Account Name",
    "VM / BM / HW",
    "On-Air or Office",
    "Static IP or DHCP",
    "Wheatstone",
    "Notes" |
Export-Csv `
    -Path $ExportPath `
    -NoTypeInformation

Write-Host ""
Write-Host "CSV Exported To:" -ForegroundColor Green
Write-Host $ExportPath -ForegroundColor Cyan
