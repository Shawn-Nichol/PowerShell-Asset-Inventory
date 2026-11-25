function Get-UserInfo
{
    $WinLogon = Get-ItemProperty `
        "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" `
        -ErrorAction SilentlyContinue

    [PSCustomObject]@{

        AutoLogonUser =
            $WinLogon.DefaultUserName
    }
}