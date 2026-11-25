function Invoke-InventoryRemoting
{
    <#
    .SYNOPSIS
        Runs the inventory on many computers in parallel and returns their rows.

    .DESCRIPTION
        Any computer that returns nothing (connection or remoting failure)
        gets an error row, so it never silently drops out of the report.
    #>
    [CmdletBinding()]
    param
    (
        [string[]]$ComputerName = @(),

        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,

        [Parameter(Mandatory)]
        [hashtable]$Settings,

        [System.Management.Automation.PSCredential]$Credential
    )

    if ($ComputerName.Count -eq 0) { return }

    Write-Verbose "Running remote inventory on $($ComputerName.Count) computer(s)"

    $InvokeParams = @{
        ComputerName  = $ComputerName
        ScriptBlock   = $ScriptBlock
        ArgumentList  = @($Settings)
        ErrorAction   = 'SilentlyContinue'
        ErrorVariable = 'RemoteErrors'
    }

    if ($Credential) { $InvokeParams.Credential = $Credential }

    $Results = @(Invoke-Command @InvokeParams)
    $Results

    # Rows for computers that returned nothing.
    $Responded = @($Results | ForEach-Object PSComputerName)

    $ComputerName |
        Where-Object { $Responded -notcontains $_ } |
        ForEach-Object {
            $Computer = $_

            $Message = @(
                $RemoteErrors |
                    Where-Object { $_.TargetObject -eq $Computer -or $_.OriginInfo.PSComputerName -eq $Computer } |
                    ForEach-Object { $_.Exception.Message }
                'No data returned'
            ) | Select-Object -First 1

            Write-Warning "$Computer - $Message"
            New-StatusRecord -ComputerName $Computer -Notes "Error: $Message"
        }
}
