function Get-AutoLogonUser
{
    <#
    .SYNOPSIS
        Returns the default (auto-logon) user name configured in Winlogon.
    #>
    [CmdletBinding()]
    param()

    $Winlogon = Get-ItemProperty `
        -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' `
        -ErrorAction SilentlyContinue

    [string]$Winlogon.DefaultUserName
}
