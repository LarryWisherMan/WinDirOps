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

Describe 'Remove-LocalDirectory' -Tag 'Unit' {

    BeforeEach {

        $BuildRoot = (Get-SamplerSourcePath -BuildRoot . )
        $functionPath = Join-Path -Path $BuildRoot -ChildPath 'Private\New-FolderDeletionResult.ps1'
        . $functionPath

        $classpath = Join-Path -Path $BuildRoot -ChildPath 'Classes\FolderDeletionResult.ps1'
        . $classpath


        # Mock `Clear-DirectoryContents` to simulate success or failure
        Mock -CommandName Clear-DirectoryContents -MockWith {
            return $true
        }

        # Mock `New-FolderDeletionResult` to simulate folder deletion results
        Mock -CommandName New-FolderDeletionResult -MockWith {
            param($Directory, $DeletionSuccess, $DeletionMessage, $ComputerName)

            return [FolderDeletionResult]::new(
                $Directory,
                $DeletionSuccess,
                $DeletionMessage,
                $ComputerName
            )
        }
    }

    Context 'When ShouldProcess returns true' {

        It 'Should clear directory contents and return success when Clear-DirectoryContents succeeds' {
            # Arrange
            $directory = "C:\Temp\OldData"

            # Act
            $result = Remove-LocalDirectory -Directory $directory -Confirm:$false

            # Assert
            Assert-MockCalled -CommandName Clear-DirectoryContents -Exactly 1 -Scope It -ParameterFilter {
                $Directory -eq $directory
            }

            Assert-MockCalled -CommandName New-FolderDeletionResult -Exactly 1 -Scope It
            $result.DeletionSuccess | Should -Be $true
            $result.DeletionMessage | Should -Be "Successfully deleted local directory '$directory'."
        }

        It 'Should return failure when Clear-DirectoryContents fails' {
            # Arrange
            $directory = "C:\Temp\OldData"

            # Mock `Clear-DirectoryContents` to simulate failure
            Mock -CommandName Clear-DirectoryContents -MockWith {
                return $false
            }

            # Act
            $result = Remove-LocalDirectory -Directory $directory -Confirm:$false

            # Assert
            Assert-MockCalled -CommandName Clear-DirectoryContents -Exactly 1
            Assert-MockCalled -CommandName New-FolderDeletionResult -Exactly 1 -Scope It
            $result.DeletionSuccess | Should -Be $false
            $result.DeletionMessage | Should -Be "Failed to delete local directory '$directory'."
        }
    }

    Context 'When ShouldProcess returns false' {

        It 'Should not attempt to delete the directory if ShouldProcess returns false' {
            # Arrange
            $directory = "C:\Temp\OldData"

            # Act
            $result = Remove-LocalDirectory -Directory $directory -WhatIf

            # Assert
            Assert-MockCalled -CommandName Clear-DirectoryContents -Times 0
            Assert-MockCalled -CommandName New-FolderDeletionResult -Times 0
        }
    }

    Context 'When an exception is thrown' {

        It 'Should return failure and an error message if an exception occurs' {
            # Arrange
            $directory = "C:\Temp\OldData"

            # Mock `Clear-DirectoryContents` to throw an exception
            Mock -CommandName Clear-DirectoryContents -MockWith { throw "Error during deletion" }

            # Act
            $result = Remove-LocalDirectory -Directory $directory -Confirm:$false

            # Assert
            $result.DeletionSuccess | Should -Be $false
            $result.DeletionMessage | Should -BeLike "Error occurred while deleting local directory 'C:\Temp\OldData'. Error during deletion"
        }
    }
}
