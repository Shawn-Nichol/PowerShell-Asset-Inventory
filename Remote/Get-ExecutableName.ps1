function Get-ExecutableName
{
    <#
    .SYNOPSIS
        Works out the main executable for an installed application.

    .DESCRIPTION
        Checks, in order:
          1. A running process started from the application's install folder
          2. The Executable named in the application definition
          3. The first .exe in the install folder (ignoring uninstallers)
          4. A running process whose path contains the program's first word
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        $Application,

        [object[]]$RunningProcesses = @()
    )

    $InstallLocation = $Application.InstallLocation.Trim('"').TrimEnd('\')

    # 1. Running process from the install folder
    if ($InstallLocation)
    {
        $Process = $RunningProcesses |
            Where-Object { $_.Path -like "$InstallLocation\*" } |
            Select-Object -First 1

        if ($Process)
        {
            return Split-Path -Path $Process.Path -Leaf
        }
    }

    # 2. Executable from the definition
    if ($Application.Definition.Executable)
    {
        return [string]$Application.Definition.Executable
    }

    # 3. First executable in the install folder
    if ($InstallLocation -and (Test-Path -Path $InstallLocation))
    {
        $Executable = Get-ChildItem -Path $InstallLocation -Filter '*.exe' -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -notmatch 'unins' } |
            Select-Object -First 1

        if ($Executable)
        {
            return $Executable.Name
        }
    }

    # 4. Running process matching the first word of the program name
    $FirstWord = ($Application.DisplayName -split '\s+')[0]

    if ($FirstWord.Length -ge 3)
    {
        $Process = $RunningProcesses |
            Where-Object { $_.Path -like "*$FirstWord*" } |
            Select-Object -First 1

        if ($Process)
        {
            return Split-Path -Path $Process.Path -Leaf
        }
    }

    return ''
}
