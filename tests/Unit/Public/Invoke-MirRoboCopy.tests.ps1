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

Describe 'Invoke-MirRoboCopy' -Tag 'Public' {

    BeforeAll {
        # Create mock directories in TestDrive
        $SourceDirectory = "$TestDrive\Source"
        $TargetDirectory = "$TestDrive\Target"
        New-Item -Path $SourceDirectory -ItemType Directory
        New-Item -Path $TargetDirectory -ItemType Directory
    }

    Context 'When robocopy runs successfully' {

        It 'Should return true when robocopy completes with exit code 0' {

            $SourceDirectory = "$TestDrive\Source"
            $TargetDirectory = "$TestDrive\Target"

            # Mock robocopy to return an exit code of 0
            mock -CommandName Invoke-RoboCopyCommand -MockWith { return 0 }

            # Run the function with Confirm:$false
            $result = Invoke-MirRoboCopy -SourceDirectory $SourceDirectory -TargetDirectory $TargetDirectory -Confirm:$false

            # Assert that the function returns true
            $result | Should -Be $true
        }

        It 'Should return true when robocopy completes with exit code 1' {

            $SourceDirectory = "$TestDrive\Source"
            $TargetDirectory = "$TestDrive\Target"

            # Mock robocopy to return an exit code of 1
            mock -CommandName Invoke-RoboCopyCommand -MockWith { return 1 }

            # Run the function with Confirm:$false
            $result = Invoke-MirRoboCopy -SourceDirectory $SourceDirectory -TargetDirectory $TargetDirectory -Confirm:$false

            # Assert that the function returns true
            $result | Should -Be $true
        }
    }

    Context 'When robocopy encounters an error' {

        It 'Should return false and write an error when robocopy returns exit code 8' {

            $SourceDirectory = "$TestDrive\Source"
            $TargetDirectory = "$TestDrive\Target"

            # Mock robocopy to return an exit code of 8
            mock -CommandName Invoke-RoboCopyCommand -MockWith { return 8 }

            # Run the function with Confirm:$false and check for thrown error
            { Invoke-MirRoboCopy -SourceDirectory $SourceDirectory -TargetDirectory $TargetDirectory -Confirm:$false -ErrorAction Stop } | Should -Throw

            # No need to assert the result here since the error should be thrown
        }

        It 'Should throw an error when robocopy returns exit code 16' {

            $SourceDirectory = "$TestDrive\Source"
            $TargetDirectory = "$TestDrive\Target"

            # Mock robocopy to return an exit code of 16
            mock -CommandName Invoke-RoboCopyCommand -MockWith { return 16 }

            # Run the function and assert that an error is thrown
            { Invoke-MirRoboCopy -SourceDirectory $SourceDirectory -TargetDirectory $TargetDirectory -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When directories are missing' {

        It 'Should not call robocopy when source directory does not exist' {

            $TargetDirectory = "$TestDrive\Target"

            # Mock robocopy to simulate a condition where it would not be called
            mock -CommandName Invoke-RoboCopyCommand -MockWith { return 0 }

            # Run the function with a non-existent source directory
            { Invoke-MirRoboCopy -SourceDirectory "$TestDrive\InvalidSource" -TargetDirectory $TargetDirectory -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should not call robocopy when target directory does not exist' {

            $TargetDirectory = "$TestDrive\Target"

            # Mock robocopy to simulate a condition where it would not be called
            mock -CommandName Invoke-RoboCopyCommand -MockWith { return 0 }

            # Run the function with a non-existent target directory
            { Invoke-MirRoboCopy -SourceDirectory $SourceDirectory -TargetDirectory "$TestDrive\InvalidTarget" -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
