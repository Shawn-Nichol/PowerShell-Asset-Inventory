function Get-ExecutableName
{
    <#
    .SYNOPSIS
        Works out the main executable for an installed application.

    .DESCRIPTION
        Builds a list of candidates in order of confidence and returns the
        first one found:
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

    $InstallFolder = $Application.InstallLocation.Trim('"').TrimEnd('\')
    $FirstWord     = ($Application.DisplayName -split '\s+')[0]

    $Candidates = @(
        $RunningProcesses |
            Where-Object { $InstallFolder -and $_.Path -like "$InstallFolder\*" } |
            ForEach-Object { Split-Path -Path $_.Path -Leaf }

        $Application.Definition.Executable

        $InstallFolder |
            Where-Object { $_ -and (Test-Path -LiteralPath $_) } |
            ForEach-Object { Get-ChildItem -LiteralPath $_ -Filter '*.exe' -ErrorAction SilentlyContinue } |
            Where-Object Name -notmatch 'unins' |
            ForEach-Object Name

        $RunningProcesses |
            Where-Object { $FirstWord.Length -ge 3 -and $_.Path -like "*$FirstWord*" } |
            ForEach-Object { Split-Path -Path $_.Path -Leaf }
    )

    [string]($Candidates | Where-Object { $_ } | Select-Object -First 1)
}
