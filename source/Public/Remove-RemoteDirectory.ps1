function Remove-RemoteDirectory {
    param (
        [string]$Directory,
        [string]$ComputerName
    )

    # Get the full script block for Clear-DirectoryContents function
    $clearDirectoryFunction = Get-FunctionScriptBlock -FunctionName 'Clear-DirectoryContents'

    if (-not $clearDirectoryFunction) {
        Write-Error "Unable to retrieve Clear-DirectoryContents function."
        return
    }

    $scriptBlock = {
        param ($remoteDirectory, $clearFunction)

        # Define the function from the passed string
        Invoke-Expression $clearFunction

        # Call the Clear-DirectoryContents function
        if (Clear-DirectoryContents -Directory $remoteDirectory) {
            return @{
                Directory      = $remoteDirectory
                Success        = $true
                Message        = "Successfully deleted remote directory '$remoteDirectory'."
                ComputerName   = $env:COMPUTERNAME
            }
        } else {
            return @{
                Directory      = $remoteDirectory
                Success        = $false
                Message        = "Failed to delete remote directory '$remoteDirectory'."
                ComputerName   = $env:COMPUTERNAME
            }
        }
    }

    try {
        # Execute the script block on the remote machine, passing the function string and directory
        $rawResult = Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock -ArgumentList $Directory, $clearDirectoryFunction

        # Construct the FolderDeletionResult object locally
        return [FolderDeletionResult]::new(
            $rawResult.Directory,
            $rawResult.Success,
            $rawResult.Message,
            $rawResult.ComputerName
        )
    } catch {
        return [FolderDeletionResult]::new(
            $Directory,
            $false,
            "Error occurred while deleting remote directory '$Directory'. $_",
            $ComputerName
        )
    }
}
