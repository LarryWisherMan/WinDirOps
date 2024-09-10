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

Describe 'Clear-DirectoryContents' -Tag 'Public' {

    BeforeEach {
        # Mock `Invoke-MirRoboCopy` to simulate success or failure
        Mock -CommandName Invoke-MirRoboCopy -MockWith {
            return $true
        }

        # Mock `Remove-Item` to prevent actual deletion
        Mock -CommandName Remove-Item
    }

    Context 'When ShouldProcess is called' {

        It 'Should proceed with clearing directory contents when ShouldProcess returns true' {
            # Arrange
            $testDirectory = "$TestDrive\OldData"

            # Act
            $result = Clear-DirectoryContents -Directory $testDirectory -Confirm:$false

            # Assert
            Assert-MockCalled -CommandName Invoke-MirRoboCopy -Exactly 1
            Assert-MockCalled -CommandName Remove-Item -Exactly 2
            $result | Should -Be $true
        }

        It 'Should not clear directory contents when ShouldProcess returns false' {
            # Arrange
            $testDirectory = "$TestDrive\OldData"


            # Act
            $result = Clear-DirectoryContents -Directory $testDirectory -WhatIf

            # Assert
            Assert-MockCalled -CommandName Invoke-MirRoboCopy -Times 0
            Assert-MockCalled -CommandName Remove-Item -Times 0

        }
    }

    Context 'When Invoke-MirRoboCopy succeeds' {

        It 'Should return true and remove the empty directory and target directory' {
            # Arrange
            $testDirectory = "$TestDrive\OldData"

            # Mock `Invoke-MirRoboCopy` to simulate success
            Mock -CommandName Invoke-MirRoboCopy -MockWith { return $true }

            # Act
            $result = Clear-DirectoryContents -Directory $testDirectory -Confirm:$false

            # Assert
            Assert-MockCalled -CommandName Invoke-MirRoboCopy -Exactly 1 -Scope It -ParameterFilter {
                $SourceDirectory -match "Temp" -and $TargetDirectory -eq $testDirectory
            }
            Assert-MockCalled -CommandName Remove-Item -Exactly 2
            $result | Should -Be $true
        }
    }

    Context 'When Invoke-MirRoboCopy fails' {

        It 'Should return false and not attempt to remove the directories' {
            # Arrange
            $testDirectory = "$TestDrive\OldData"

            # Mock `Invoke-MirRoboCopy` to simulate failure
            Mock -CommandName Invoke-MirRoboCopy -MockWith { return $false }

            # Act
            $result = Clear-DirectoryContents -Directory $testDirectory -Confirm:$false

            # Assert
            Assert-MockCalled -CommandName Invoke-MirRoboCopy -Exactly 1
            Assert-MockCalled -CommandName Remove-Item -Times 0
            $result | Should -Be $false
        }
    }

    Context 'When an exception is thrown' {

        It 'Should not throw on an error' {
            # Arrange
            $testDirectory = "$TestDrive\OldData"

            # Mock `Invoke-MirRoboCopy` to throw an exception
            Mock -CommandName Invoke-MirRoboCopy -MockWith { throw "Exception in RoboCopy" }

            # Act
            { Clear-DirectoryContents -Directory $testDirectory -Confirm:$false -ErrorAction Continue } | Should -Not -Throw

        }

        It 'Should return false and write an error' {
            # Arrange
            $testDirectory = "C:\Test\OldData"

            # Mock `Invoke-MirRoboCopy` to throw an exception
            Mock -CommandName Invoke-MirRoboCopy -MockWith { throw "Exception in RoboCopy" }

            # Act
            $result = Clear-DirectoryContents -Directory $testDirectory -Confirm:$false -ErrorAction Continue

            # Assert
            $result | Should -Be $false
        }
    }
}
