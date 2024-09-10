<#
.SYNOPSIS
    Executes the Robocopy command to copy or mirror directories.

.DESCRIPTION
    This function runs the Robocopy utility to mirror or copy files from a source directory to a target directory.
    You can pass additional Robocopy parameters to customize the operation, with /mir (mirror) being the default.

.PARAMETER SourceDirectory
    The path to the source directory that will be copied or mirrored to the target directory.

.PARAMETER TargetDirectory
    The path to the target directory where the source directory's contents will be copied or mirrored.

.PARAMETER AdditionalParams
    Optional parameters to customize the Robocopy operation.
    Defaults to /mir (mirror), but you can specify other parameters such as /e, /r:5, /w:10, etc.

.EXAMPLE
    Invoke-RobocopyCommand -SourceDirectory "C:\Source" -TargetDirectory "C:\Target"

    Mirrors the contents of C:\Source to C:\Target using the default /mir parameter.

.EXAMPLE
    Invoke-RobocopyCommand -SourceDirectory "C:\Source" -TargetDirectory "C:\Target" -AdditionalParams @("/e", "/r:2", "/w:5")

    Copies all files from C:\Source to C:\Target, including empty directories (/e), with a retry count of 2 (/r:2) and a wait time of 5 seconds between retries (/w:5).

.NOTES
    RoboCopy exit codes:
    - 0: No files were copied.
    - 1: One or more files were copied successfully.
    - 8: Some files or directories could not be copied (failure).
    - 16: Fatal error (failure).

    The function returns the exit code from Robocopy.

.LINK
    https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy

#>
function Invoke-RobocopyCommand
{
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceDirectory,

        [Parameter(Mandatory = $true)]
        [string]$TargetDirectory,

        [string[]]$AdditionalParams = @()  # Default to /mir
    )

    # Build the robocopy command with parameters
    $robocopyArgs = @($SourceDirectory, $TargetDirectory) + $AdditionalParams

    # Call robocopy directly
    $result = robocopy @robocopyArgs

    return $result
}
