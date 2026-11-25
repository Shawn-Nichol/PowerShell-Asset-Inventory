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

    $Programs = Get-ItemProperty -Path $UninstallKeys -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName }

    foreach ($Program in $Programs)
    {
        $Definition = Find-ApplicationDefinition `
            -DisplayName $Program.DisplayName `
            -Applications $Applications

        if ($Definition)
        {
            [PSCustomObject]@{
                DisplayName     = [string]$Program.DisplayName
                DisplayVersion  = [string]$Program.DisplayVersion
                InstallLocation = [string]$Program.InstallLocation
                Definition      = $Definition
            }
        }
    }
}
