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
- Network classification and IP discovery.
- Sentinel/HASP license discovery and reporting.
- Auto-logon account identification.
- Wheatstone network interface detection.
- Executable and application version discovery.
- CSV report generation for asset management and compliance tracking.

## Purpose

Many organizations have specialized software, licensing dongles, virtual machines, and operational systems that are difficult to inventory using traditional asset management tools. This script provides a repeatable and scalable method for collecting application, licensing, hardware, and user information across Windows environments.

## Output

The script generates a timestamped CSV containing the following information:

- Application Name
- Functionality
- End User / Server / Service Classification
- Service or Application Type
- Executable Name
- Software Version
- Licensing Information
- HASP ID
- Computer Name
- Operating System
- Primary User or Service Account
- Hardware Type
- Network Information
- Wheatstone Connectivity
- Engineering Notes

The resulting report provides a clean, one-row-per-application inventory that can be used for audits, software lifecycle planning, licensing reviews, infrastructure assessments, and migration projects.

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
