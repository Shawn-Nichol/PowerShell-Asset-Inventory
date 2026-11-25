function Get-ExecutableInfo
{
    param
    (
        $Application,

        $RunningProcesses
    )

    $Executable = ""

    # Running process match first

    foreach ($Process in $RunningProcesses)
    {
        if (
            $Process.Path -like
            "*$($Application.DisplayName.Split(' ')[0])*"
        )
        {
            $Executable =
                Split-Path $Process.Path -Leaf

            break
        }
    }

    # Fall back to install location

    if (
        -not $Executable -and
        $Application.InstallLocation
    )
    {
        $ExeFiles =
            Get-ChildItem `
                -Path $Application.InstallLocation `
                -Filter *.exe `
                -ErrorAction SilentlyContinue |

            Where-Object {
                $_.Name -notmatch "Uninstall"
            }

        $Executable =
            $ExeFiles |
            Select-Object `
                -ExpandProperty Name `
                -First 1
    }

    return $Executable
}