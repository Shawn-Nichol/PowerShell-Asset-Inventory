
# =====================================================
# Broadcast Audit Script
# One Row Per Application
# =====================================================


# =====================================================
# LOAD FUNCTIONS
# =====================================================

Get-ChildItem `
    -Path "$PSScriptRoot\Functions\*.ps1" `
    -ErrorAction SilentlyContinue |

ForEach-Object {
    . $_.FullName
}

# =====================================================
# LOAD CONFIGURATION
# =====================================================

. "$PSScriptRoot\Config\Applications.ps1"

# =====================================================
# COMPUTER LIST
# =====================================================

$Computers = Get-ComputerList


$Results = foreach ($Computer in $Computers)
{

# =====================================================
# OFFLINE CHECK
# =====================================================
if (-not (Test-Connection $Computer -Count 1 -Quiet))
{
    Write-Warning "$Computer - Offline"

    $BaseRecord =
        Get-BaseRecord `
            -ComputerName $Computer `
            -Notes "Offline"

    New-AuditRecord `
        -Base $BaseRecord `
        -Notes "Offline"

    continue
}

# =====================================================
# WINRM VALIDATION
# =====================================================

$WinRM_OK = Test-WinRM $Computer

if (-not $WinRM_OK)
{
    $WinRM_OK = Repair-WinRM $Computer
}

if (-not $WinRM_OK)
{
    continue
}

Invoke-Command -ComputerName $Computer -ScriptBlock {

# =====================================================
# ERROR HANDLING
# =====================================================

$ErrorActionPreference = "Stop"

# =====================================================
# MACHINE INFORMATION
# =====================================================

$SystemInfo = Get-SystemInfo

$OS = $SystemInfo.OS

$MachineType = $SystemInfo.MachineType

# =====================================================
# NETWORK INFORMATION
# =====================================================

$NetworkInfo = Get-NetworkInfo

$AddressType = $NetworkInfo.AddressType

$OnAirOffice = $NetworkInfo.OnAirOffice

$WheatstoneIP = $NetworkInfo.WheatstoneIP

$IPAddress = $NetworkInfo.IPAddress



# =====================================================
# USER INFORMATION
# =====================================================

$UserInfo = Get-UserInfo

$AutoLogonUser = $UserInfo.AutoLogonUser

# =====================================================
# BASE RECORD
# =====================================================

# =====================================================
# BASE RECORD
# =====================================================

$BaseRecord =
    Get-BaseRecord `
        -ComputerName $env:COMPUTERNAME `
        -OS $OS `
        -AutoLogonUser $AutoLogonUser `
        -MachineType $MachineType `
        -OnAirOffice $OnAirOffice `
        -AddressType $AddressType `
        -WheatstoneIP $WheatstoneIP




# =====================================================
# BURLI DISCOVERY
# =====================================================

$BurliInfo = Get-BurliInfo

$BurliInstalled = $BurliInfo.Installed

$BurliHaspID = $BurliInfo.HaspID

$BurliLicenseType = $BurliInfo.LicenseType


# =====================================================
# CREATE BURLI ROW
# =====================================================

if ($BurliInstalled)
{
	New-AuditRecord `
		-Base $BaseRecord `
		-ApplicationName "Burli" `
		-Functionality "News Content Software" `
		-UserType "End User" `
	        -ServiceType "Application" `
	        -Executable "Burli.exe" `
	        -Version "246c-HL" `
	        -LicenseType $BurliLicenseType `
	        -HaspID ([string]$BurliHaspID) `
	        -Notes "Discovered from Burli Registry"
}

# =====================================================
# APPLICATION DISCOVERY
# =====================================================

$InstalledApps = Get-InstalledApplications


# =====================================================
# PROCESS DISCOVERY
# =====================================================

$RunningProcesses = Get-RunningProcesses

# =====================================================
# BUILD ONE ROW PER APPLICATION
# =====================================================

foreach ($Application in $InstalledApps)
{
    $AppInfo =
        Get-ApplicationDefinition `
            -ApplicationName $Application.DisplayName `
            -ApplicationDefinitions $ApplicationDefinitions

    # =====================================================
    # EXECUTABLE DISCOVERY
    # =====================================================

    $Executable =
        Get-ExecutableInfo `
            -Application $Application `
            -RunningProcesses $RunningProcesses

    if ($AppInfo)
    {
        New-AuditRecord `
            -Base $BaseRecord `
            -ApplicationName $Application.DisplayName `
            -Functionality $AppInfo.Functionality `
            -UserType $AppInfo.UserType `
            -ServiceType $AppInfo.ServiceType `
            -Executable $(
                if ($Executable)
                {
                    $Executable
                }
                else
                {
                    $AppInfo.Executable
                }
            ) `
            -Version $Application.DisplayVersion `
            -LicenseType $(
                if ($Application.DisplayName -match "Burli")
                {
                    $BurliLicenseType
                }
                else
                {
                    ""
                }
            ) `
            -HaspID $(
                if ($Application.DisplayName -match "Burli")
                {
                    [string]$BurliHaspID
                }
                else
                {
                    ""
                }
            )
    }
    else
    {
        New-AuditRecord `
            -Base $BaseRecord `
            -ApplicationName $Application.DisplayName `
            -ServiceType "Application" `
            -Executable $Executable `
            -Version $Application.DisplayVersion `
            -Notes "Application definition required"
    }
}
}


# =====================================================
# EXPORT CSV
# =====================================================

Export-Audit -Results $Results