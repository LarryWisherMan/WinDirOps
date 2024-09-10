<#
.SYNOPSIS
    Mirrors the contents of a source directory to a target directory using RoboCopy.

.DESCRIPTION
    This function mirrors the contents of a source directory to a target directory using the RoboCopy utility.
    It ensures that the contents of the target directory exactly match the source directory by syncing them.

.PARAMETER SourceDirectory
    The path of the source directory whose contents will be mirrored to the target directory.

.PARAMETER TargetDirectory
    The path of the target directory where the source directory contents will be mirrored.

.EXAMPLE
    Invoke-MirRoboCopy -SourceDirectory "C:\SourceFolder" -TargetDirectory "C:\TargetFolder"

    Mirrors the contents of "C:\SourceFolder" to "C:\TargetFolder".

.NOTES
    This function is a low-level utility used by other functions like `Clear-DirectoryContents`
    to handle the mirroring operation.

    RoboCopy exit codes:
    0  = No files were copied
    1  = One or more files were copied successfully (even if some files were skipped)
    8  = Some files or directories could not be copied (failure)
    16 = Fatal error (failure)

    Exit codes 8 and higher are considered failures in this function.
#>
function Invoke-MirRoboCopy
{
    [OutputType([System.Boolean])]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceDirectory,

        [Parameter(Mandatory = $true)]
        [string]$TargetDirectory
    )

    try
    {

        # Validate that the source directory exists
        if (-not (Test-Path -Path $SourceDirectory -PathType Container))
        {
            throw "Source directory '$SourceDirectory' does not exist."
        }

        # Validate that the target directory exists
        if (-not (Test-Path -Path $TargetDirectory -PathType Container))
        {
            throw "Target directory '$TargetDirectory' does not exist."
        }

        if ($PSCmdlet.ShouldProcess($TargetDirectory, "Mirror directory from '$SourceDirectory'"))
        {
            # Use robocopy to mirror the source directory to the target directory
            $result = Invoke-RoboCopyCommand -SourceDirectory $SourceDirectory -TargetDirectory $TargetDirectory  -AdditionalParams '/mir'

            # Check robocopy result
            if ($result -ge 8)
            {
                throw "RoboCopy encountered a failure with code $result."
            }

            return $true
        }
    }
    catch
    {
        Write-Error "RoboCopy failed from '$SourceDirectory' to '$TargetDirectory'. Error: $_"
        return $false
    }
}
