function Get-LogonInfo
{
    <#
    .SYNOPSIS
        Returns whether auto-logon is enabled, the auto-logon user, and the
        last user who logged on.

    .DESCRIPTION
        Winlogon keeps DefaultUserName even when auto-logon is off, so the
        auto-logon user is only reported when AutoAdminLogon is enabled.
    #>
    [CmdletBinding()]
    param()

    $Winlogon = Get-ItemProperty `
        -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' `
        -ErrorAction SilentlyContinue

    $LogonUI = Get-ItemProperty `
        -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI' `
        -ErrorAction SilentlyContinue

    $AutoLogonEnabled = "$($Winlogon.AutoAdminLogon)" -eq '1'

    $YesNo          = @{ $true = 'Yes'; $false = 'No' }
    $AutoLogonUsers = @{ $true = [string]$Winlogon.DefaultUserName; $false = '' }

    [PSCustomObject]@{
        AutoLogonEnabled = $YesNo[$AutoLogonEnabled]
        AutoLogonUser    = $AutoLogonUsers[$AutoLogonEnabled]
        LastLoggedOnUser = [string]$LogonUI.LastLoggedOnUser
    }
}
