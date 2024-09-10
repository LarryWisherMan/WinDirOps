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
            $deletionInfo = @{
                Directory    = $Directory
                ComputerName = $env:COMPUTERNAME
            }

            if (Clear-DirectoryContents -Directory $Directory -Confirm:$false)
            {
                $deletionInfo.DeletionSuccess = $true
                $deletionInfo.DeletionMessage = "Successfully deleted local directory '$Directory'."
            }
            else
            {
                $deletionInfo.DeletionSuccess = $false
                $deletionInfo.DeletionMessage = "Failed to delete local directory '$Directory'."
            }

            return New-FolderDeletionResult @deletionInfo
        }
    }
    catch
    {
        $deletionInfo = @{
            Directory       = $Directory
            DeletionSuccess = $false
            DeletionMessage = "Error occurred while deleting local directory '$Directory'. $_"
            ComputerName    = $env:COMPUTERNAME
        }
        return New-FolderDeletionResult @deletionInfo
    }
}
