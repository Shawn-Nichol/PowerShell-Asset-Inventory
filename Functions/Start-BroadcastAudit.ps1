Get-ChildItem `
    -Path "$PSScriptRoot\Functions\*.ps1" |
ForEach-Object {
    . $_.FullName
}

. "$PSScriptRoot\Config\Applications.ps1"

Start-BroadcastAudit