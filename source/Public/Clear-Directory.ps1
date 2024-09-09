function Clear-Directory {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [string]$Directory,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$ComputerName = $env:COMPUTERNAME  # Default to local computer
    )

    process {
        if ($PSCmdlet.ShouldProcess($Directory, "Delete directory on $ComputerName")) {
            $result = Remove-DirectoryByType -Directory $Directory -ComputerName $ComputerName
            Write-Information -MessageData $result.DeletionMessage -Tags "DeleteOperation"
            return $result
        }
    }
}
