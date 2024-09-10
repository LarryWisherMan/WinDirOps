<#
.SYNOPSIS
    Clears only the contents of a directory without deleting the directory itself.

.DESCRIPTION
    This function clears the contents of a directory by mirroring it with an empty temporary directory.
    It does not delete the directory itself but removes all files and subfolders within the specified directory.
    It uses `Invoke-MirRoboCopy` to sync an empty directory with the target directory, effectively clearing it.

.PARAMETER Directory
    The path of the directory whose contents will be cleared.

.EXAMPLE
    Clear-DirectoryContents -Directory "C:\Temp\OldData"

    Clears the contents in the "C:\Temp\OldData" directory but does not remove the directory itself.

.NOTES
    This function is for clearing the contents of a directory while preserving the directory itself.
    To delete both the directory and its contents, use `Clear-Directory` or `Remove-DirectoryByType`.
#>
function Clear-DirectoryContents
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [OutputType([System.Boolean])]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory
    )

    try
    {
        # Create a temporary empty directory
        $emptyDir = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
        mkdir $emptyDir | Out-Null

        if ($PSCmdlet.ShouldProcess($Directory, "Clear directory contents"))
        {
            # Use Invoke-MirRoboCopy to fast-delete the directory contents by syncing an empty directory
            $syncSuccess = Invoke-MirRoboCopy -SourceDirectory $emptyDir -TargetDirectory $Directory -confirm:$false

            if ($syncSuccess)
            {
                # Remove the target directory after clearing its contents
                Remove-Item -Path $Directory -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path $emptyDir -Recurse -Force -ErrorAction SilentlyContinue

                return $true
            }
            else
            {
                return $false
            }
        }
    }
    catch
    {
        Write-Error "Failed to clear directory contents for $Directory. Error: $_"
        return $false
    }
}
