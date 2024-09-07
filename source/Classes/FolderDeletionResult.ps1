class FolderDeletionResult {
    [string]$FolderPath
    [bool]$DeletionSuccess
    [string]$DeletionMessage
    [string]$ComputerName

    # Constructor to initialize the properties
    FolderDeletionResult([string]$folderPath, [bool]$deletionSuccess, [string]$deletionMessage, [string]$computerName) {
        $this.FolderPath = $folderPath
        $this.DeletionSuccess = $deletionSuccess
        $this.DeletionMessage = $deletionMessage
        $this.ComputerName = $computerName
    }
}
