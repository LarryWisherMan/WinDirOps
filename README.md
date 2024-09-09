<p align="center">
  <img src="https://raw.githubusercontent.com/LarryWisherMan/ModuleIcons/main/WinDirOps.png" alt="WinDirOps Icon" width="200" />
</p>


# WinDirOps

The **WinDirOps** module provides a comprehensive set of PowerShell functions to interact with the Windows file system, offering a simplified interface for common directory operations such as clearing, removing, and managing directories both locally and remotely. It abstracts the complexity of working with local and network file paths, handling both direct access and remote operations via PowerShell remoting.

The module is designed to handle tasks like deleting directory contents, syncing empty directories for fast deletion, and removing directories with detailed error handling. It enables seamless interaction with the file system, whether performing maintenance tasks on local folders or managing directories across multiple remote systems.

This module can be used independently or as a dependency for higher-level file management or system configuration modules, offering flexibility and reliability in directory management operations.

---

### **Key Features:**

- **Clear directory contents (local and remote)**.
- **Remove directories safely** with built-in `-WhatIf` and `-Confirm` support for safer operations.
- **Sync directories** for fast deletion using efficient methods like `robocopy` via the `Invoke-MirRoboCopy` function.
- **Handle both local and UNC paths** seamlessly, converting paths automatically for remote access.
- **Remote computer availability checks** before performing operations, ensuring directories are managed only if the target computer is reachable.
- **Detailed status reporting** on directory operations, providing success or failure messages, including remote computer reachability.

---

### **Typical Use Cases:**

- **Automating system cleanup**: Regularly clear out temporary or outdated directories, both on local machines and remote servers.
- **Managing directories during deployments**: Clear and reset build directories as part of an automated deployment or CI/CD process.
- **Remote directory management**: Delete, clear, or manage folders on remote systems without needing manual access. Functions now check if the remote machine is online before proceeding.
- **File system maintenance**: Use **WinDirOps** to ensure file system cleanliness and order during regular system maintenance tasks.

---

### **Installation**

To install **WinDirOps**, you can either download the module from the repository or use PowerShell's `Install-Module` command to install from the [PSGallery](https://www.powershellgallery.com/packages/WinDirOps):

```powershell
Install-Module -Name WinDirOps
```

Alternatively, clone the repository and import the module directly:

```powershell
git clone https://github.com/YourUsername/WinDirOps
Import-Module .\WinDirOps\WinDirOps.psd1
```

---

### **Usage**

#### Example 1: Safely Deleting a Remote Directory

The `Remove-DirectoryByType` function allows you to safely delete directories on local or remote machines, and now supports `-WhatIf` and `-Confirm`:

```powershell
Remove-DirectoryByType -Directory "D:\OldFiles" -ComputerName "RemotePC" -WhatIf
```

This command will simulate the deletion of the `D:\OldFiles` directory on the remote machine `RemotePC`. No changes will be made because of the `-WhatIf` flag, allowing you to preview the operation.

#### Example 2: Clearing Directory Contents Locally

You can use `Clear-DirectoryContents` to remove the contents of a directory without deleting the directory itself. This function supports `-Confirm` for additional safety:

```powershell
Clear-DirectoryContents -Directory "C:\Temp\Logs" -Confirm
```

This will clear the contents of the `C:\Temp\Logs` directory and prompt for confirmation before proceeding.

#### Example 3: Handling Offline Remote Computers

Functions like `Remove-RemoteDirectory` now automatically check if the remote computer is reachable using `Test-ComputerPing`. If the remote machine is offline, the function returns a `FolderDeletionResult` with a clear error message:

```powershell
$Result = Remove-RemoteDirectory -Directory "D:\OldFiles" -ComputerName "RemotePC"

if (-not $Result.DeletionSuccess) {
    Write-Host "Error: $($Result.DeletionMessage)"
}
```

In this case, if `RemotePC` is offline, you'll receive a message indicating the computer is unreachable, and no deletion attempt will be made.

---

### **Key Functions**

#### `Clear-Directory`
Deletes an entire directory and its contents either on the local or a remote computer. Supports `-WhatIf` and `-Confirm` to preview or confirm the operation.

#### `Clear-DirectoryContents`
Clears the contents of a directory without deleting the directory itself. It uses `robocopy` under the hood via the `Invoke-MirRoboCopy` function for efficient clearing.

#### `Remove-DirectoryByType`
Handles directory deletion on both local and remote machines. Automatically determines whether to use `Remove-LocalDirectory` or `Remove-RemoteDirectory` based on the provided `ComputerName`.

#### `Invoke-MirRoboCopy`
A utility function to mirror directories using `robocopy`. This function is used by `Clear-DirectoryContents` for fast directory clearing.

#### `Remove-LocalDirectory`
Deletes a local directory and its contents. Uses `Clear-DirectoryContents` to clear the directory before removal.

#### `Remove-RemoteDirectory`
Deletes a directory and its contents on a remote computer. Automatically checks if the remote machine is reachable before attempting the operation.

---

### **Contributing**

Feel free to fork this repository and submit pull requests. Contributions are welcome in the form of bug fixes, feature enhancements, and additional documentation. 

---
