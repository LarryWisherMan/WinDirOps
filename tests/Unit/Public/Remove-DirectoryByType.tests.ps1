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

Describe 'Remove-DirectoryByType' -Tag 'public' {

    BeforeEach {

        $BuildRoot = (Get-SamplerSourcePath -BuildRoot . )
        $functionPath = Join-Path -Path $BuildRoot -ChildPath 'Private\New-FolderDeletionResult.ps1'
        . $functionPath

        $classpath = Join-Path -Path $BuildRoot -ChildPath 'Classes\FolderDeletionResult.ps1'
        . $classpath

        # Mock the Remove-LocalDirectory and Remove-RemoteDirectory functions
        Mock -CommandName Remove-LocalDirectory -MockWith {
            param ($Directory)
            New-FolderDeletionResult -Directory $Directory -DeletionSuccess $true -DeletionMessage "Local directory $Directory deleted successfully." -ComputerName $env:COMPUTERNAME
        }

        Mock -CommandName Remove-RemoteDirectory -MockWith {
            param ($Directory, $ComputerName)
            New-FolderDeletionResult -Directory $Directory -DeletionSuccess $true -DeletionMessage "Remote Directory $Directory deleted successfully." -ComputerName $ComputerName
        }
    }

    Context 'When deleting a directory on the local computer' {

        It 'Should call Remove-LocalDirectory when the directory is local' {
            # Arrange
            $localDirectory = "C:\Temp\Logs"
            $localComputerName = $env:COMPUTERNAME

            # Act
            $result = Remove-DirectoryByType -Directory $localDirectory  -Confirm:$false

            # Assert
            Assert-MockCalled -CommandName Remove-LocalDirectory -Exactly 1 -Scope It -ParameterFilter {
                $Directory -eq $localDirectory
            }

            # Check that the function returns the expected result
            $result.DeletionMessage | Should -Be "Local directory $localDirectory deleted successfully."
        }

        It 'Should return the correct FolderDeletionResult for local directory' {
            # Arrange
            $localDirectory = "C:\Temp\Logs"

            # Act
            $result = Remove-DirectoryByType -Directory $localDirectory -Confirm:$false

            # Assert
            $result.getType().FullName | Should -Be "FolderDeletionResult"
            $result.FolderPath | Should -Be $localDirectory
            $result.ComputerName | Should -Be $env:COMPUTERNAME
            $result.DeletionMessage | Should -Be "Local directory $localDirectory deleted successfully."
        }
    }

    Context 'When deleting a directory on a remote computer' {

        It 'Should call Remove-RemoteDirectory when the directory is on a remote computer' {
            # Arrange
            $remoteDirectory = "D:\OldFiles"
            $remoteComputerName = "RemotePC"

            # Act
            $result = Remove-DirectoryByType -Directory $remoteDirectory -ComputerName $remoteComputerName -Confirm:$false

            # Assert
            Assert-MockCalled -CommandName Remove-RemoteDirectory -Exactly 1 -Scope It -ParameterFilter {
                $Directory -eq $remoteDirectory -and $ComputerName -eq $remoteComputerName
            }

            # Check that the function returns the expected result
            $result.DeletionMessage | Should -Be "Remote directory $remoteDirectory deleted successfully."
        }

        It 'Should return the correct FolderDeletionResult for remote directory' {
            # Arrange
            $remoteDirectory = "D:\OldFiles"
            $remoteComputerName = "RemotePC"

            # Act
            $result = Remove-DirectoryByType -Directory $remoteDirectory -ComputerName $remoteComputerName -Confirm:$false

            # Assert
            $result.getType().FullName | Should -Be "FolderDeletionResult"
            $result.FolderPath | Should -Be $remoteDirectory
            $result.ComputerName | Should -Be $remoteComputerName
            $result.DeletionMessage | Should -Be "Remote directory $remoteDirectory deleted successfully."
        }
    }

    Context 'When ShouldProcess is called' {

        It 'Should proceed with deletion when ShouldProcess returns true for local directory' {
            # Arrange
            $localDirectory = "C:\Temp\Logs"

            # Act
            $result = Remove-DirectoryByType -Directory $localDirectory -Confirm:$false

            # Assert
            Assert-MockCalled -CommandName Remove-LocalDirectory -Exactly 1
        }

        It 'Should not proceed with deletion when ShouldProcess returns false for local directory' {
            # Arrange
            $localDirectory = "C:\Temp\Logs"

            # Act
            $result = Remove-DirectoryByType -Directory $localDirectory -WhatIf

            # Assert
            Assert-MockCalled -CommandName Remove-LocalDirectory -Times 0
        }

        It 'Should proceed with deletion when ShouldProcess returns true for remote directory' {
            # Arrange
            $remoteDirectory = "D:\OldFiles"
            $remoteComputerName = "RemotePC"

            # Act
            $result = Remove-DirectoryByType -Directory $remoteDirectory -ComputerName $remoteComputerName -Confirm:$false

            # Assert
            Assert-MockCalled -CommandName Remove-RemoteDirectory -Exactly 1
        }

        It 'Should not proceed with deletion when ShouldProcess returns false for remote directory' {
            # Arrange
            $remoteDirectory = "D:\OldFiles"
            $remoteComputerName = "RemotePC"

            # Act
            $result = Remove-DirectoryByType -Directory $remoteDirectory -ComputerName $remoteComputerName -WhatIf

            # Assert
            Assert-MockCalled -CommandName Remove-RemoteDirectory -Times 0
        }
    }
}
