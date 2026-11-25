function New-RemoteScript
{
    <#
    .SYNOPSIS
        Packages every function in the Functions folder (and subfolders)
        into one script block that runs Get-ComputerInventory.

    .DESCRIPTION
        Functions loaded in this session do not exist on remote computers.
        Sending their source with the command means nothing has to be
        installed on the targets.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$FunctionPath
    )

    $FunctionCode = Get-ChildItem -Path $FunctionPath -Filter '*.ps1' -Recurse |
        ForEach-Object { Get-Content -Path $_.FullName -Raw }

    $ScriptText = @(
        'param($Settings)'
        $FunctionCode
        'Get-ComputerInventory -Settings $Settings'
    ) -join "`r`n"

    [scriptblock]::Create($ScriptText)
}
