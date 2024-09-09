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
        # Return FolderDeletionResult indicating the computer is offline
        return [FolderDeletionResult]::new(
            $Directory,
            $false,
            "The remote computer '$ComputerName' is offline or unreachable.",
            $ComputerName
        )
    }


    # Get the full script block for Clear-DirectoryContents function
    $clearDirectoryFunction = Get-FunctionScriptBlock -FunctionName 'Clear-DirectoryContents'
    $IvokeMirRoboCopyFunction = Get-FunctionScriptBlock -FunctionName 'Invoke-MirRoboCopy'

    if (-not $clearDirectoryFunction -or -not $IvokeMirRoboCopyFunction)
    {
        Write-Error "Unable to retrieve Clear-DirectoryContents function."
        return
    }

    $scriptBlock = {
        param ($remoteDirectory, $clearFunction, $RoboCopyFunction)

        # Define the function from the passed string
        Invoke-Expression $clearFunction, $RoboCopyFunction

        # Call the Clear-DirectoryContents function
        if (Clear-DirectoryContents -Directory $remoteDirectory -confirm:$false)
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
            # Execute the script block on the remote machine, passing the function string and directory
            $rawResult = Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock -ArgumentList $Directory, $clearDirectoryFunction, $invokeMirRoboCopyFunction

            # Construct the FolderDeletionResult object locally
            return [FolderDeletionResult]::new(
                $rawResult.Directory,
                $rawResult.Success,
                $rawResult.Message,
                $rawResult.ComputerName
            )
        }
    }
    catch
    {
        return [FolderDeletionResult]::new(
            $Directory,
            $false,
            "Error occurred while deleting remote directory '$Directory'. $_",
            $ComputerName
        )
    }
}
