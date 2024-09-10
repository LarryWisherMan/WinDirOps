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

Describe 'Remove-RemoteDirectory' -Tag 'public' {

    BeforeEach {

        $BuildRoot = (Get-SamplerSourcePath -BuildRoot . )
        $functionPath = Join-Path -Path $BuildRoot -ChildPath 'Private\New-FolderDeletionResult.ps1'
        . $functionPath

        $classpath = Join-Path -Path $BuildRoot -ChildPath 'Classes\FolderDeletionResult.ps1'
        . $classpath



        # Mock `Test-ComputerPing` to simulate checking if the remote computer is online
        Mock -CommandName Test-ComputerPing -MockWith {
            return $true
        }

        # Mock `Get-FunctionScriptBlock` to return a string representation of functions
        Mock -CommandName Get-FunctionScriptBlock -MockWith {
            return "return"
        }

        # Mock `Invoke-Command` to simulate executing a script block on a remote machine
        Mock -CommandName Invoke-Command -MockWith {
            param (
                $ComputerName,
                $ScriptBlock,
                $ArgumentList
            )

            # Ensure the ComputerName is correctly passed as a string
            if (-not [string]::IsNullOrEmpty($ComputerName))
            {
                return @{
                    Directory    = $ArgumentList[0]  # Directory argument
                    Success      = $true
                    Message      = "Successfully deleted remote directory '$($ArgumentList[0])'."
                    ComputerName = $ComputerName -as [string]
                }
            }
            else
            {
                throw "Invalid ComputerName argument"
            }
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

    Context 'When the remote computer is offline' {

        It 'Should return failure when the remote computer is unreachable' {
            # Arrange
            $directory = "D:\RemoteData"
            $remoteComputerName = "RemotePC"

            # Mock `Test-ComputerPing` to simulate that the remote computer is offline
            Mock -CommandName Test-ComputerPing -MockWith {
                return $false
            }

            # Act
            $result = Remove-RemoteDirectory -Directory $directory -ComputerName $remoteComputerName -Confirm:$false

            # Assert
            $result.DeletionSuccess | Should -Be $false
            $result.DeletionMessage | Should -Be "The remote computer '$remoteComputerName' is offline or unreachable."
            $result.ComputerName | Should -Be $remoteComputerName
        }
    }

    Context 'When required functions cannot be retrieved' {

        It 'Should return an error when required functions are not found' {
            # Arrange
            $directory = "D:\RemoteData"
            $remoteComputerName = "RemotePC"

            # Mock `Get-FunctionScriptBlock` to simulate failure in retrieving functions
            Mock -CommandName Get-FunctionScriptBlock -MockWith {
                return $null
            }

            # Act
            { Remove-RemoteDirectory -Directory $directory -ComputerName $remoteComputerName -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When ShouldProcess returns true' {

        It 'Should delete the remote directory and return success' {
            # Arrange
            $directory = "D:\RemoteData"
            $remoteComputerName = "RemotePC"

            # Act
            $result = Remove-RemoteDirectory -Directory $directory -ComputerName $remoteComputerName -Confirm:$false

            # Assert that `Invoke-Command` was called with the correct parameters
            Assert-MockCalled -CommandName Invoke-Command -Exactly 1 -Scope It -ParameterFilter {
                $ComputerName -eq $remoteComputerName -and $ArgumentList[0] -eq $directory
            }

            # Assert that the result is successful
            $result.DeletionSuccess | Should -Be $true
            $result.DeletionMessage | Should -Be "Successfully deleted remote directory '$directory'."
            $result.ComputerName | Should -Be $remoteComputerName
        }
    }

    Context 'When an exception is thrown' {

        It 'Should return failure and an error message if an exception occurs' {
            # Arrange
            $directory = "D:\RemoteData"
            $remoteComputerName = "RemotePC"

            # Mock `Invoke-Command` to throw an exception
            Mock -CommandName Invoke-Command -MockWith { throw "Error during remote deletion" }

            # Act
            $result = Remove-RemoteDirectory -Directory $directory -ComputerName $remoteComputerName -Confirm:$false

            # Assert that the result indicates failure and contains the correct error message
            $result.DeletionSuccess | Should -Be $false
            $result.DeletionMessage | Should -BeLike "Error occurred while deleting remote directory '$directory'. Error during remote deletion"
            $result.ComputerName | Should -Be $remoteComputerName
        }
    }
}
