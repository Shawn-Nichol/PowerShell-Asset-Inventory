function Get-RebootPending
{
    <#
    .SYNOPSIS
        Returns 'Yes' when Windows is waiting for a restart, otherwise 'No'.

    .DESCRIPTION
        Checks the three common signals:
          - Component Based Servicing (Windows features and updates)
          - Windows Update
          - Pending file rename operations (often left by installers)
    #>
    [CmdletBinding()]
    param()

    $PendingRenames = Get-ItemProperty `
        -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
        -Name 'PendingFileRenameOperations' `
        -ErrorAction SilentlyContinue

    $Signals = @(
        Test-Path -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
        Test-Path -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
        [bool]$PendingRenames
    )

    $YesNo = @{ $true = 'Yes'; $false = 'No' }

    $YesNo[$Signals -contains $true]
}
