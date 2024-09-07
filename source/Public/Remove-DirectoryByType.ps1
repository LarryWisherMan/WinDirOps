function Remove-DirectoryByType {
    param (
        [string]$Directory,
        [string]$ComputerName = $env:COMPUTERNAME
    )

    $isLocal = $ComputerName -eq $env:COMPUTERNAME

    if ($isLocal) {
        return Remove-LocalDirectory -Directory $Directory
    } else {
        return Remove-RemoteDirectory -Directory $Directory -ComputerName $ComputerName
    }
}
