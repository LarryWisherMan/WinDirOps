# WinDirOps

The **WinDirOps** module provides a comprehensive set of PowerShell functions to interact with the Windows file system, offering a simplified interface for common directory operations such as clearing, removing, and managing directories both locally and remotely. It abstracts the complexity of working with local and network file paths, handling both direct access and remote operations via PowerShell remoting.

The module is designed to handle tasks like deleting directory contents, syncing empty directories for fast deletion, and removing directories with detailed error handling. It enables seamless interaction with the file system, whether performing maintenance tasks on local folders or managing directories across multiple remote systems.

This module can be used independently or as a dependency for higher-level file management or system configuration modules, offering flexibility and reliability in directory management operations.

---

### **Key Features:**

- **Clear directory contents (local and remote).**
- **Remove directories safely** with built-in confirmation and error handling.
- **Sync directories** for fast deletion using efficient methods like `robocopy`.
- **Handle both local and UNC paths** seamlessly, converting paths automatically for remote access.
- **Detailed status reporting** on directory operations, providing success or failure messages.

---

### **Typical Use Cases:**

- **Automating system cleanup:** Regularly clear out temporary or outdated directories, both on local machines and remote servers.
- **Managing directories during deployments:** Clear and reset build directories as part of an automated deployment or CI/CD process.
- **Remote directory management:** Delete, clear, or manage folders on remote systems without needing manual access.
- **File system maintenance:** Use **WinDirOps** to ensure file system cleanliness and order during regular system maintenance tasks.

