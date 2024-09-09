function Clear-DirectoryContents {
    param (
        [string]$Directory
    )

    try {
        # Create a temporary directory
        $emptyDir = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
        mkdir $emptyDir | Out-Null

        # Use robocopy to fast-delete the directory contents by syncing an empty directory
        robocopy $emptyDir $Directory /mir | Out-Null

        # Remove the target directory and the temporary directory
        Remove-Item -Path $Directory -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $emptyDir -Recurse -Force -ErrorAction SilentlyContinue

        return $true
    } catch {
        Write-Error "Failed to clear directory contents for $Directory. Error: $_"
        return $false
    }
}
