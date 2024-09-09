<#
.SYNOPSIS
    Deletes a specified directory on the local or remote computer.

.DESCRIPTION
    This function attempts to delete an entire directory and its contents either on the local or a remote computer.
    It determines whether the operation is local or remote using the `ComputerName` parameter.
    Internally, it delegates to `Remove-DirectoryByType` to handle the deletion, making this a high-level function
    for directory deletion on any machine.

.PARAMETER Directory
    The path of the directory to be deleted.

.PARAMETER ComputerName
    The name of the computer where the directory resides. Defaults to the local computer.

.EXAMPLE
    Clear-Directory -Directory "C:\Temp\Logs"

    This example deletes the "C:\Temp\Logs" directory on the local machine.

.EXAMPLE
    Clear-Directory -Directory "D:\OldFiles" -ComputerName "RemotePC"

    This example deletes the "D:\OldFiles" directory on a remote computer named "RemotePC".

.NOTES
    This function determines whether the operation is local or remote and uses the appropriate
    function (either `Remove-LocalDirectory` or `Remove-RemoteDirectory`) to perform the deletion.
    It supports `-WhatIf` and `-Confirm` for previewing or confirming the operation.
#>

function Clear-Directory
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [string]$Directory,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$ComputerName = $env:COMPUTERNAME  # Default to local computer
    )

    process
    {
        if ($PSCmdlet.ShouldProcess($Directory, "Delete directory on $ComputerName"))
        {
            $result = Remove-DirectoryByType -Directory $Directory -ComputerName $ComputerName -Confirm:$false
            Write-Information -MessageData $result.DeletionMessage -Tags "DeleteOperation"
            return $result
        }
    }
}
