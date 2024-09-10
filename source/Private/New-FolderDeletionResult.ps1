function New-FolderDeletionResult
{
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory,

        [Parameter(Mandatory = $true)]
        [bool]$DeletionSuccess,

        [Parameter(Mandatory = $true)]
        [string]$DeletionMessage,

        [Parameter(Mandatory = $true)]
        [string]$ComputerName
    )

    return [FolderDeletionResult]::new(
        $Directory,
        $DeletionSuccess,
        $DeletionMessage,
        $ComputerName
    )
}
