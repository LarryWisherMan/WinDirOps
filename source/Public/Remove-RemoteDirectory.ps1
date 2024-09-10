<#
.SYNOPSIS
    Deletes a remote directory and its contents.

.DESCRIPTION
    This function deletes a directory and its contents on a remote computer.
    It sends a script block to the remote computer to clear the directory contents using `Clear-DirectoryContents`,
    then deletes the directory itself.

.PARAMETER Directory
    The path of the remote directory to be deleted.

.PARAMETER ComputerName
    The name of the remote computer where the directory is located.

.EXAMPLE
    Remove-RemoteDirectory -Directory "D:\OldFiles" -ComputerName "RemotePC"

    Deletes the "D:\OldFiles" directory and its contents on the remote computer "RemotePC".

.NOTES
    This function is specifically for remote directories.
    Use `Remove-LocalDirectory` for local directory deletions.
#>

function Remove-RemoteDirectory
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory,

        [Parameter(Mandatory = $true)]
        [string]$ComputerName
    )

    # Check if the remote computer is online
    if (-not (Test-ComputerPing -ComputerName $ComputerName))
    {
        $deletionInfo = @{
            Directory       = $Directory
            DeletionSuccess = $false
            DeletionMessage = "The remote computer '$ComputerName' is offline or unreachable."
            ComputerName    = $ComputerName
        }
        return New-FolderDeletionResult @deletionInfo
    }

    # Get the script blocks for Clear-DirectoryContents and Invoke-MirRoboCopy functions
    $clearDirectoryFunction = Get-FunctionScriptBlock -FunctionName 'Clear-DirectoryContents'
    $invokeMirRoboCopyFunction = Get-FunctionScriptBlock -FunctionName 'Invoke-MirRoboCopy'

    if (-not $clearDirectoryFunction -or -not $invokeMirRoboCopyFunction)
    {
        Write-Error "Unable to retrieve required functions."
        return
    }

    $scriptBlock = {
        param ($remoteDirectory, $clearFunction, $roboCopyFunction)

        # Define the functions from the passed strings
        & $clearFunction
        & $roboCopyFunction

        # Call the Clear-DirectoryContents function
        if (Clear-DirectoryContents -Directory $remoteDirectory -Confirm:$false)
        {
            return @{
                Directory    = $remoteDirectory
                Success      = $true
                Message      = "Successfully deleted remote directory '$remoteDirectory'."
                ComputerName = $env:COMPUTERNAME
            }
        }
        else
        {
            return @{
                Directory    = $remoteDirectory
                Success      = $false
                Message      = "Failed to delete remote directory '$remoteDirectory'."
                ComputerName = $env:COMPUTERNAME
            }
        }
    }

    try
    {
        if ($PSCmdlet.ShouldProcess("$ComputerName`: $Directory", "Delete remote directory"))
        {
            # Execute the script block on the remote machine
            $rawResult = Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock -ArgumentList $Directory, $clearDirectoryFunction, $invokeMirRoboCopyFunction

            $deletionInfo = @{
                Directory       = $rawResult.Directory
                DeletionSuccess = $rawResult.Success
                DeletionMessage = $rawResult.Message
                ComputerName    = $rawResult.ComputerName
            }
            return New-FolderDeletionResult @deletionInfo
        }
    }
    catch
    {
        $deletionInfo = @{
            Directory       = $Directory
            DeletionSuccess = $false
            DeletionMessage = "Error occurred while deleting remote directory '$Directory'. $_"
            ComputerName    = $ComputerName
        }
        return New-FolderDeletionResult @deletionInfo
    }
}
