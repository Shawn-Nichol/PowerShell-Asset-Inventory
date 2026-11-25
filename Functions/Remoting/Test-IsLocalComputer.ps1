function Test-IsLocalComputer
{
    <#
    .SYNOPSIS
        Returns $true when the name refers to the computer running the script.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$ComputerName
    )

    $LocalNames = @(
        '.'
        'localhost'
        '127.0.0.1'
        '::1'
        $env:COMPUTERNAME
        "$env:COMPUTERNAME.$env:USERDNSDOMAIN"
    )

    $LocalNames -contains $ComputerName
}
