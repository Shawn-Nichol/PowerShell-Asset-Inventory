function Get-ComputerList
{
    $ComputerList = Join-Path `
        $PSScriptRoot `
        "..\Config\BroadcastComputers.txt"

    if (Test-Path $ComputerList)
    {
        $Computers =
            Get-Content $ComputerList |

            Where-Object {
                $_.Trim() -ne "" -and
                $_ -notmatch '^#'
            }

        Write-Host ""
        Write-Host "Loaded $($Computers.Count) computers from file." `
            -ForegroundColor Cyan

        return $Computers
    }

    Write-Host ""
    Write-Host "Computer list not found." `
        -ForegroundColor Yellow

    Write-Host "Running local audit on: $env:COMPUTERNAME" `
        -ForegroundColor Cyan

    return @($env:COMPUTERNAME)
}