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

    if ($Winlogon -and $Winlogon.DefaultUserName)
    {
        return [string]$Winlogon.DefaultUserName
    }

    return ''
}
