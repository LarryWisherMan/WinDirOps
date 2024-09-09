# Changelog for WinDirOps

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added core functions
- Updated build file for release
- Added new function `Invoke-MirRoboCopy` to wrap robocopy functionality
- Added `ShouldProcess` support to all public directory-related functions to enable safer operations using `-WhatIf` and `-Confirm`:
  - Functions updated:
    - `Clear-Directory`
    - `Clear-DirectoryContents`
    - `Remove-LocalDirectory`
    - `Remove-RemoteDirectory`
    - `Remove-DirectoryByType`
    - `Invoke-MirRoboCopy`
- Added remote computer availability check using `Test-ComputerPing` (see [WisherTools.Helpers](https://github.com/LarryWisherMan/WisherTools.Helpers)) for functions dealing with remote directories (`Remove-RemoteDirectory` and `Remove-DirectoryByType`). These functions now return a `FolderDeletionResult` indicating if the computer is offline and abort the operation if it is unreachable.
- Added enhanced error handling to return detailed failure messages, including when a remote computer is offline or the deletion operation fails.

### Changed

- Updated functions to implement `Invoke-MirRoboCopy` for faster and safer directory content clearing using robocopy.
- Suppressed nested confirmation prompts in internal function calls by passing `-Confirm:$false` to internal operations, preventing multiple confirmation requests during execution.
- Improved comment-based help for all functions to clearly explain local vs. remote operations, the role of `ShouldProcess`, and how the remote computer checks are handled.
