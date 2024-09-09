function Remove-LocalDirectory {
    param (
        [string]$Directory
    )

    try {
        if (Clear-DirectoryContents -Directory $Directory) {
            return [FolderDeletionResult]::new(
                $Directory,
                $true,
                "Successfully deleted local directory '$Directory'.",
                $env:COMPUTERNAME
            )
        } else {
            return [FolderDeletionResult]::new(
                $Directory,
                $false,
                "Failed to delete local directory '$Directory'.",
                $env:COMPUTERNAME
            )
        }
    } catch {
        return [FolderDeletionResult]::new(
            $Directory,
            $false,
            "Error occurred while deleting local directory '$Directory'. $_",
            $env:COMPUTERNAME
        )
    }
}
