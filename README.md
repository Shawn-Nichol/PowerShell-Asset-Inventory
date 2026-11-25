# PowerShell Asset Inventory

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows&logoColor=white)
![Protocol](https://img.shields.io/badge/Protocol-WinRM%20%7C%20CIM-00599E)
![Output](https://img.shields.io/badge/Output-CSV_Reports-green?logo=microsoftcsv&logoColor=white)
![Discovery](https://img.shields.io/badge/Discovery-Sentinel_HASP_%7C_Burli-purple)


A PowerShell-based asset inventory and application auditing tool for Windows environments. The script remotely scans workstations and servers, discovers installed applications, gathers licensing and system information, and exports the results into a structured CSV report.

## Features

- Multi-system inventory collection using a configurable computer list.
- Automatic online/offline device detection.
- WinRM validation with optional remote remediation.
- Discovery of installed applications and broadcast-specific software including:
  - Burli
  - GV Stratus
  - OpenMedia
  - VoxPro
  - iMediaLogger
  - CSRDS
  - WideOrbit
  - Various encoder, automation, and support applications
- Hardware and virtualization detection (VMware, Hyper-V, and physical hardware).
- BIOS details and serial number, CPU, RAM, and C: drive size and free space.
- Security settings: Secure Boot, TPM, BitLocker, RDP, SMBv1, Windows Firewall and pending reboots.
- TeamViewer version and ID discovery.
- Network classification and IP discovery.
- Sentinel/HASP license discovery and reporting.
- Auto-logon status and account, plus the last logged-on user.
- Wheatstone network interface detection.
- Executable and application version discovery.
- CSV report generation for asset management and compliance tracking.

## Purpose

Many organizations have specialized software, licensing dongles, virtual machines, and operational systems that are difficult to inventory using traditional asset management tools. This script provides a repeatable and scalable method for collecting application, licensing, hardware, and user information across Windows environments.

## Output

The script generates a timestamped CSV containing the following information:

- Computer Name
- On-Air or Office Location
- Operating System
- Hardware Type (VM or physical model)
- Serial Number
- BIOS Manufacturer, Version and Release Date
- CPU
- RAM (GB)
- C: Drive Size and Free Space (GB)
- Auto-Logon Enabled and Auto-Logon User
- Last Logged-On User
- Static IP or DHCP
- Wheatstone Connectivity
- Secure Boot, TPM and BitLocker (C:) Status
- RDP and SMBv1 Status
- Windows Firewall Profiles
- Reboot Pending
- Application Name
- Software Version
- Functionality
- End User / Server / Service Classification
- Service or Application Type
- Executable Name
- Licensing Information and HASP ID
- TeamViewer ID
- Notes

Rows are sorted by computer, then application. Computer details repeat on each of that computer's rows, so every row can be filtered on its own.

The report can include TeamViewer IDs and user names, so treat it as sensitive and store it accordingly. The resulting report provides a clean, one-row-per-application inventory that can be used for audits, software lifecycle planning, licensing reviews, infrastructure assessments, and migration projects.

## Getting Started

Requirements: Windows PowerShell 5.1 or later, WinRM enabled on target computers, and admin rights on the targets. PsExec is only needed for `-RepairWinRM`.

1. Copy `Config\Computers.example.txt` to `Config\Computers.txt` and list your hostnames, one per line.
2. Copy `Config\Network.example.psd1` to `Config\Network.psd1` and set your subnets.
3. Review `Config\Applications.psd1` and add or describe the applications you want to track.
4. Optional: for applications you don't want published, such as security tools, copy `Config\Applications.local.example.psd1` to `Config\Applications.local.psd1` and add them there. The format is the same, and its entries are checked first.
5. Run the inventory:

```powershell
# Audit every computer in Config\Computers.txt
.\Start-Inventory.ps1

# Audit specific computers and show progress details
.\Start-Inventory.ps1 -ComputerName STUDIO-01, STUDIO-02 -Verbose

# Use alternate credentials and try to fix WinRM where it is not responding
.\Start-Inventory.ps1 -RepairWinRM -Credential (Get-Credential)

# Full parameter help
Get-Help .\Start-Inventory.ps1 -Full
```

Reports are saved to the `Output` folder as `AssetInventory-<date>_<time>.csv`. Every target appears in the report; computers that could not be audited get a row explaining why (Offline, WinRM unavailable, or the error message).

`Computers.txt`, `Network.psd1`, `Applications.local.psd1` and `Output\` are git-ignored, so hostnames, internal subnets, privately tracked applications and reports are never committed.

## Project Structure

```
Start-Inventory.ps1        Entry point: check each computer, collect rows, export
Config\
  Applications.psd1        Applications to track and how to describe them
  Applications.local.example.psd1
                           Template for privately tracked applications (git-ignored copy)
  Network.example.psd1     Template for environment-specific subnets
  Computers.example.txt    Template for the computer list
Functions\
  Setup\                   Settings, target list, shared helpers
  Remoting\                Computer status checks, WinRM, parallel remoting
  System\                  Machine details: OS, BIOS, hardware, network, users
  Security\                Secure Boot, TPM, BitLocker, RDP, SMBv1, firewall, pending reboot
  Applications\            Installed applications, executables, Burli licensing, TeamViewer ID
  Reporting\               Report rows, CSV export, summary
```

`Start-Inventory.ps1` reads as three steps: work out the status of each computer (local, ready, offline or WinRM unavailable), collect the rows, then export. Each function does one job and lives in its own file, grouped into subfolders by topic. The code uses pipelines, lookup tables and early returns instead of nested if/else blocks.

Settings are PowerShell data files (`.psd1`) loaded with `Import-PowerShellDataFile`, which reads them as data and never executes them. The functions are packaged into a single script block and sent with `Invoke-Command`, so nothing needs to be installed on the target computers, and all reachable targets are audited in parallel.

## How It Works

### Overall flow

`Start-Inventory.ps1` loads the settings, checks each computer, collects the rows and exports the report. The status of each computer decides which path it takes.

```mermaid
flowchart TD
    Start(["Start-Inventory.ps1"])

    subgraph Config["Config folder"]
        Apps[("Applications.psd1")]
        LocalApps[("Applications.local.psd1<br/>optional, git-ignored")]
        Net[("Network.psd1")]
        List[("Computers.txt")]
    end

    subgraph Setup["1. Setup"]
        Import["Import-InventorySettings"]
        Targets["Get-TargetComputer"]
        Default["Get-ValueOrDefault"]
        Package["New-RemoteScript<br/>packages Functions into one script block"]
    end

    subgraph Check["2. Check each computer"]
        Status["Get-ComputerStatus"]
        IsLocal["Test-IsLocalComputer"]
        WinRM["Test-WinRM"]
        Repair["Repair-WinRM<br/>only with -RepairWinRM"]
    end

    subgraph Collect["3. Collect rows"]
        LocalRun["Get-ComputerInventory<br/>runs directly on this computer"]
        Remoting["Invoke-InventoryRemoting<br/>runs on all ready computers in parallel"]
        StatusRec["New-StatusRecord<br/>row explaining why a computer was skipped"]
    end

    subgraph Output["4. Output"]
        Export["Export-InventoryReport"]
        Csv[("Output folder<br/>AssetInventory-date.csv")]
        Summary["Write-InventorySummary"]
    end

    Start --> Setup
    Apps --> Import
    LocalApps --> Import
    Net --> Import
    List --> Targets
    Import --> Default
    Targets --> Default

    Setup --> Status
    Status --> IsLocal
    Status --> WinRM
    Status --> Repair
    Repair --> WinRM

    Status -->|Local| LocalRun
    Status -->|Ready| Remoting
    Status -->|Offline or WinRM unavailable| StatusRec
    Remoting -->|computer returned nothing| StatusRec
    Package -.->|script block| LocalRun
    Package -.->|script block| Remoting

    LocalRun --> Export
    Remoting --> Export
    StatusRec --> Export
    Export --> Csv
    Export --> Summary
```

### What runs on each computer

`Get-ComputerInventory` is the function sent to every target. It gathers the machine details once, then builds one row per tracked application. If nothing matches it returns a "No tracked applications found" row, and if anything fails it returns an error row, so every computer appears in the report.

```mermaid
flowchart LR
    Inv(["Get-ComputerInventory"])

    Inv --> Machine["Get-MachineInfo<br/>details shared by every row"]
    Machine --> Sys["Get-SystemInfo<br/>OS, VM or hardware model"]
    Machine --> NetInfo["Get-NetworkInfo<br/>DHCP or Static, On-Air or Office, Wheatstone IP"]
    Machine --> Bios["Get-BiosInfo<br/>BIOS and serial number"]
    Machine --> Hw["Get-HardwareInfo<br/>CPU, RAM, C: drive"]
    Machine --> Logon["Get-LogonInfo<br/>auto-logon and last user"]
    Machine --> Sec["Get-SecurityInfo"]
    Sec --> SecChecks["Get-SecureBootStatus, Get-TpmStatus,<br/>Get-BitLockerStatus, Get-RdpStatus,<br/>Get-Smb1Status, Get-FirewallStatus,<br/>Get-RebootPending"]
    Machine --> Base["New-BaseRecord"]

    Inv --> Burli["Get-BurliInfo"]
    Burli --> Hasp["Get-HaspLicenseType<br/>asks the local HASP License Manager"]

    Inv --> TV["Get-TeamViewerInfo<br/>TeamViewer ID"]

    Inv --> Proc["Get-RunningProcess"]

    Inv --> Installed["Get-InstalledApplication<br/>reads the Uninstall registry keys"]
    Installed --> Find["Find-ApplicationDefinition<br/>matches against Applications.psd1"]

    Inv --> AppRec["New-ApplicationRecord<br/>one per installed application"]
    AppRec --> Exe["Get-ExecutableName"]
    AppRec --> Audit["New-AuditRecord<br/>defines the CSV columns"]

    Inv --> BurliRec["New-BurliRegistryRecord<br/>Burli found only in the registry"]
    BurliRec --> Audit

    Inv -->|no matches or error| Audit
```

### Function reference

| Folder | Function | What it does |
|---|---|---|
| Setup | `Import-InventorySettings` | Loads `Applications.psd1`, the optional `Applications.local.psd1` and `Network.psd1`, and fills in defaults |
| Setup | `Get-TargetComputer` | Returns computers from `-ComputerName`, `Computers.txt`, or this computer |
| Setup | `Get-ValueOrDefault` | Returns a value, or a fallback when it is empty |
| Remoting | `New-RemoteScript` | Packages the Functions folder into one script block for remoting |
| Remoting | `Get-ComputerStatus` | Returns Local, Ready, Offline or WinRM unavailable |
| Remoting | `Test-IsLocalComputer` | Checks whether a name refers to this computer |
| Remoting | `Test-WinRM` | Checks whether a computer answers PowerShell remoting |
| Remoting | `Repair-WinRM` | Enables WinRM with PsExec (only with `-RepairWinRM`) |
| Remoting | `Invoke-InventoryRemoting` | Runs the inventory on all ready computers in parallel |
| System | `Get-ComputerInventory` | Audits one computer and returns its rows |
| System | `Get-MachineInfo` | Collects the details shared by every row |
| System | `Get-SystemInfo` | Returns the OS and whether it is a VM or physical hardware |
| System | `Get-NetworkInfo` | Returns DHCP or Static, On-Air or Office, and the Wheatstone IP |
| System | `Get-BiosInfo` | Returns the BIOS manufacturer, version, release date and serial number |
| System | `Get-HardwareInfo` | Returns the CPU, RAM, and C: drive size and free space |
| System | `Get-LogonInfo` | Returns auto-logon status and user, and the last logged-on user |
| System | `Get-RunningProcess` | Lists running processes and their paths |
| Security | `Get-SecurityInfo` | Collects all the security settings for a computer |
| Security | `Get-SecureBootStatus` | Returns Enabled, Disabled or Not supported (legacy BIOS) |
| Security | `Get-TpmStatus` | Returns the TPM version and whether it is enabled |
| Security | `Get-BitLockerStatus` | Returns BitLocker protection on the C: drive |
| Security | `Get-RdpStatus` | Returns whether Remote Desktop connections are allowed |
| Security | `Get-Smb1Status` | Returns whether the outdated SMBv1 protocol is enabled |
| Security | `Get-FirewallStatus` | Returns the state of each Windows Firewall profile |
| Security | `Get-RebootPending` | Returns whether Windows is waiting for a restart |
| Applications | `Get-TeamViewerInfo` | Returns the TeamViewer ID from the registry |
| Applications | `Get-BurliInfo` | Returns whether Burli is installed and its HASP ID |
| Applications | `Get-HaspLicenseType` | Returns Dedicated or Network HASP |
| Applications | `Get-InstalledApplication` | Finds installed programs that match a tracked application |
| Applications | `Find-ApplicationDefinition` | Returns the first definition whose pattern matches a program name |
| Applications | `New-ApplicationRecord` | Builds the row for one installed application |
| Applications | `Get-ExecutableName` | Works out the application's main executable |
| Applications | `New-BurliRegistryRecord` | Adds a Burli row when Burli is only in the registry |
| Reporting | `New-StatusRecord` | Creates a row for a computer that could not be audited |
| Reporting | `New-BaseRecord` | Holds the machine details used in every row |
| Reporting | `New-AuditRecord` | Creates one report row; its properties define the CSV columns |
| Reporting | `Export-InventoryReport` | Writes the rows to a timestamped CSV |
| Reporting | `Write-InventorySummary` | Prints totals and the report location |

## Why I Built It

I needed a reliable way to document application deployments, licensing dependencies, and workstation configurations across distributed Windows environments. Manual audits were time-consuming, difficult to maintain, and often inconsistent.

This project automates the discovery process and produces standardized reporting that can be used by engineering, operations, and IT teams to make informed decisions about infrastructure management, software licensing, and future technology upgrades.

## Technologies Used

- PowerShell
- WinRM
- PSExec
- WMI/CIM
- Windows Registry
- CSV Reporting
- Sentinel HASP Licensing
- Remote Systems Administration

## Example Use Cases

- Annual or quarterly asset audits
- IT asset inventory collection
- Software license validation
- Infrastructure modernization projects
- Workstation migration planning
- Disaster recovery inventories
- Compliance reviews

## Future Enhancements

- Active Directory integration
- Automated scheduling and reporting
- Database-backed inventory storage
- Web dashboard visualization
- Historical asset tracking
- Enhanced application fingerprinting
- Extended application support

---
