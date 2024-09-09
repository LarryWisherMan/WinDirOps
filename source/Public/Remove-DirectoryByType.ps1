<#
.SYNOPSIS
    Deletes a directory either locally or remotely based on the computer name provided.

.DESCRIPTION
    This function deletes a directory either on the local machine or a remote machine depending on
    the computer name provided. It determines whether the operation is local or remote and calls the
    appropriate function (either `Remove-LocalDirectory` or `Remove-RemoteDirectory`).
    It supports `-WhatIf` and `-Confirm` to allow users to preview or confirm the deletion before it is performed.

.PARAMETER Directory
    The path of the directory to be deleted.

.PARAMETER ComputerName
    The name of the computer where the directory resides. Defaults to the local computer.

.EXAMPLE
    Remove-DirectoryByType -Directory "C:\Temp\Logs"

    Deletes the directory "C:\Temp\Logs" from the local machine.

.NOTES
    This function determines whether the directory is on the local or remote computer and uses
    the appropriate method to delete it.
#>

function Remove-DirectoryByType
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory,

        [Parameter(Mandatory = $false)]
        [string]$ComputerName = $env:COMPUTERNAME
    )

    $isLocal = $ComputerName -eq $env:COMPUTERNAME

    if ($PSCmdlet.ShouldProcess("$ComputerName': $Directory", "Delete directory by type"))
    {
        if ($isLocal)
        {
            return Remove-LocalDirectory -Directory $Directory -confirm:$false
        }
        else
        {
            return Remove-RemoteDirectory -Directory $Directory -ComputerName $ComputerName -confirm:$false
        }
    }
}
