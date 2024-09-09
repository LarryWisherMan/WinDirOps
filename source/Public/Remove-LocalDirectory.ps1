<#
.SYNOPSIS
    Deletes a local directory and its contents.

.DESCRIPTION
    This function deletes a specified directory on the local computer.
    It first clears the contents of the directory and then removes the directory itself.

.PARAMETER Directory
    The path of the local directory to be deleted.

.EXAMPLE
    Remove-LocalDirectory -Directory "C:\Temp\OldData"

    Deletes the "C:\Temp\OldData" directory and its contents on the local machine.

.NOTES
    This function works only on local directories. For remote directories, use `Remove-RemoteDirectory`.
#>


function Remove-LocalDirectory
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory
    )

    try
    {
        if ($PSCmdlet.ShouldProcess($Directory, "Delete local directory"))
        {
            if (Clear-DirectoryContents -Directory $Directory -Confirm:$false)
            {
                return [FolderDeletionResult]::new(
                    $Directory,
                    $true,
                    "Successfully deleted local directory '$Directory'.",
                    $env:COMPUTERNAME
                )
            }
            else
            {
                return [FolderDeletionResult]::new(
                    $Directory,
                    $false,
                    "Failed to delete local directory '$Directory'.",
                    $env:COMPUTERNAME
                )
            }
        }
    }
    catch
    {
        return [FolderDeletionResult]::new(
            $Directory,
            $false,
            "Error occurred while deleting local directory '$Directory'. $_",
            $env:COMPUTERNAME
        )
    }
}
