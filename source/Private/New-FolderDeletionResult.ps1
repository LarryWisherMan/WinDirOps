<#
.SYNOPSIS
    Creates a new FolderDeletionResult object.

.DESCRIPTION
    The `New-FolderDeletionResult` function creates and returns a new `FolderDeletionResult` object,
    which contains information about the deletion of a directory, including the directory path,
    whether the deletion was successful, a message about the result, and the computer name
    on which the deletion took place.

.PARAMETER Directory
    The path of the directory that was being deleted.

.PARAMETER DeletionSuccess
    A boolean value indicating whether the deletion was successful.
    `$true` if the deletion was successful, `$false` otherwise.

.PARAMETER DeletionMessage
    A message describing the result of the deletion process.

.PARAMETER ComputerName
    The name of the computer where the directory deletion occurred.

.EXAMPLE
    $result = New-FolderDeletionResult -Directory "C:\Temp\OldData" -DeletionSuccess $true -DeletionMessage "Successfully deleted." -ComputerName "LocalHost"

    This example creates a `FolderDeletionResult` object with information about the successful deletion
    of the "C:\Temp\OldData" directory on the local computer "LocalHost".

.EXAMPLE
    $result = New-FolderDeletionResult -Directory "D:\RemoteData" -DeletionSuccess $false -DeletionMessage "Failed to delete." -ComputerName "RemotePC"

    This example creates a `FolderDeletionResult` object with information about the failed deletion
    of the "D:\RemoteData" directory on the remote computer "RemotePC".

.NOTES
    This function is used to encapsulate the result of a directory deletion operation,
    providing a structured way to handle and return the outcome of such operations.
#>

function New-FolderDeletionResult
{
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory,

        [Parameter(Mandatory = $true)]
        [bool]$DeletionSuccess,

        [Parameter(Mandatory = $true)]
        [string]$DeletionMessage,

        [Parameter(Mandatory = $true)]
        [string]$ComputerName
    )

    return [FolderDeletionResult]::new(
        $Directory,
        $DeletionSuccess,
        $DeletionMessage,
        $ComputerName
    )
}
