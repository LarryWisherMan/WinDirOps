

Write-Host $classpath
if (-not ([System.Management.Automation.PSTypeName]'FolderDeletionResult').Type)
{
    Write-Host "FolderDeletionResult class not loaded."
}
else
{
    Write-Host "FolderDeletionResult class loaded successfully."
}

BeforeAll {
    $script:dscModuleName = "WinDirOps"

    Import-Module -Name $script:dscModuleName

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName


}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'Clear-Directory' -Tag 'Unit' {

    BeforeEach {

        $BuildRoot = (Get-SamplerSourcePath -BuildRoot . )
        $functionPath = Join-Path -Path $BuildRoot -ChildPath 'Private\New-FolderDeletionResult.ps1'
        . $functionPath

        $classpath = Join-Path -Path $BuildRoot -ChildPath 'Classes\FolderDeletionResult.ps1'
        . $classpath


        # Mock the Remove-DirectoryByType function using the helper function New-FolderDeletionResult
        Mock -CommandName Remove-DirectoryByType -MockWith {
            param ($Directory, $ComputerName)
            New-FolderDeletionResult -Directory $Directory -DeletionSuccess $true -DeletionMessage "Directory $Directory deleted successfully." -ComputerName $ComputerName
        }
    }

    Context 'When deleting a directory on the local computer' {

        It 'Should call Remove-DirectoryByType with the local computer name' {
            # Arrange
            $localDirectory = "C:\Temp\Logs"
            $localComputerName = $env:COMPUTERNAME

            # Act
            $result = Clear-Directory -Directory $localDirectory -Confirm:$false

            # Assert
            Assert-MockCalled -CommandName Remove-DirectoryByType -Exactly 1 -Scope It -ParameterFilter {
                $Directory -eq $localDirectory -and $ComputerName -eq $localComputerName
            }

            # Check that the function returns the expected result
            $result.DeletionMessage | Should -Be "Directory $localDirectory deleted successfully."
        }

        It 'Should return the correct FolderDeletionResult' {


            # Arrange
            $localDirectory = "C:\Temp\Logs"

            # Act
            $result = Clear-Directory -Directory $localDirectory -Confirm:$false

            # Assert
            $result.getType().FullName | Should -Be "FolderDeletionResult"
            $result.FolderPath | Should -Be $localDirectory
            $result.ComputerName | Should -Be $env:COMPUTERNAME
            $result.DeletionMessage | Should -Be "Directory $localDirectory deleted successfully."
        }
    }

    Context 'When deleting a directory on a remote computer' {

        It 'Should call Remove-DirectoryByType with the remote computer name' {
            # Arrange
            $remoteDirectory = "D:\OldFiles"
            $remoteComputerName = "RemotePC"

            # Act
            $result = Clear-Directory -Directory $remoteDirectory -ComputerName $remoteComputerName -Confirm:$false

            # Assert
            Assert-MockCalled -CommandName Remove-DirectoryByType -Exactly 1 -Scope It -ParameterFilter {
                $Directory -eq $remoteDirectory -and $ComputerName -eq $remoteComputerName
            }

            # Check that the function returns the expected result
            $result.DeletionMessage | Should -Be "Directory $remoteDirectory deleted successfully."
        }

        It 'Should return the correct FolderDeletionResult for remote computer' {
            # Arrange
            $remoteDirectory = "D:\OldFiles"
            $remoteComputerName = "RemotePC"

            # Act
            $result = Clear-Directory -Directory $remoteDirectory -ComputerName $remoteComputerName -Confirm:$false

            # Assert
            $result.getType().FullName | Should -Be "FolderDeletionResult"
            $result.FolderPath | Should -Be $remoteDirectory
            $result.ComputerName | Should -Be $remoteComputerName
            $result.DeletionMessage | Should -Be "Directory $remoteDirectory deleted successfully."
        }
    }

    Context 'When ShouldProcess is called' {

        It 'Should proceed with deletion when ShouldProcess returns true' {
            # Arrange
            $localDirectory = "C:\Test"

            # Act
            $result = Clear-Directory -Directory $localDirectory -Confirm:$false

            # Assert
            Assert-MockCalled -CommandName Remove-DirectoryByType -Exactly 1
        }

        It 'Should not proceed with deletion when ShouldProcess returns false' {
            # Arrange
            $localDirectory = "C:\Test"

            # Act
            $result = Clear-Directory -Directory $localDirectory -WhatIf

            # Assert
            Assert-MockCalled -CommandName Remove-DirectoryByType -Times 0
        }
    }
}
