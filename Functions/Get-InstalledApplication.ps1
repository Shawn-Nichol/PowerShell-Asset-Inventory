function Get-InstalledApplication
{
    <#
    .SYNOPSIS
        Returns installed programs that match a tracked application definition.

    .DESCRIPTION
        Reads the 64-bit and 32-bit Uninstall registry keys and returns one
        object per matching program, with the matched definition attached.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [object[]]$Applications
    )

    $UninstallKeys = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    Get-ItemProperty -Path $UninstallKeys -ErrorAction SilentlyContinue |
        Where-Object DisplayName |
        ForEach-Object {
            [PSCustomObject]@{
                DisplayName     = [string]$_.DisplayName
                DisplayVersion  = [string]$_.DisplayVersion
                InstallLocation = [string]$_.InstallLocation
                Definition      = Find-ApplicationDefinition -DisplayName $_.DisplayName -Applications $Applications
            }
        } |
        Where-Object Definition
}
