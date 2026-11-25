function Get-TeamViewerInfo
{
    <#
    .SYNOPSIS
        Returns the TeamViewer ID of this computer, or '' when TeamViewer
        is not installed.

    .DESCRIPTION
        The ID is the ClientID value under the TeamViewer registry key
        (64-bit or 32-bit). Treat reports containing it as sensitive: with
        the password, the ID gives remote access to the computer.
    #>
    [CmdletBinding()]
    param()

    $TeamViewerKeys = @(
        'HKLM:\SOFTWARE\TeamViewer'
        'HKLM:\SOFTWARE\WOW6432Node\TeamViewer'
    )

    $ClientID = Get-ItemProperty -Path $TeamViewerKeys -ErrorAction SilentlyContinue |
        Where-Object { $_.ClientID } |
        Select-Object -First 1 -ExpandProperty ClientID

    [PSCustomObject]@{
        TeamViewerID = [string]$ClientID
    }
}
