# 🚀 Rclone Sync Manager

A lightweight, interactive shell application designed to streamline your backup workflow. **Rclone Sync Manager** acts as a user-friendly wrapper for `rclone`, allowing you to manage source directories and destinations (Cloud or Local) without memorizing complex flags.

---

## ✨ Features

* **🎨 Color-Coded Interface:** High-visibility terminal output for better readability.
* **💾 Persistent Configuration:** Saves paths and flags to `~/.sync_mgr_config` for easy reuse.
* **🔄 Dual-Destination Support:** Sync to Cloud (e.g., Google Drive), Local (e.g., USB), or both.
* **🛡️ Safety First:** Integrated **Dry Run** mode to test your sync logic before execution.
* **🛠️ Dynamic Editing:** Modify your source, destination, or rclone flags on-the-fly.

---

## 📋 Prerequisites

Before running the script, ensure you have:
1.  **Rclone installed** (`rclone --version`).
2.  **A configured remote** (e.g., `gdrive`) via `rclone config`.

---

## 🚀 Getting Started

### 1. Installation
Save the script as `sync_mgr.sh` and make it executable:
```bash
chmod +x sync_mgr.sh
```

### 2. Usage
Run the script from your terminal:
```bash
./sync_mgr.sh
```

---

## ⚙️ Configuration

The script manages a hidden config file at `~/.sync_mgr_config`.

| Variable | Description | Default Example |
| :--- | :--- | :--- |
| **SOURCE** | Local folder to back up | `/media/xeno/Storage/Pictures` |
| **GDRIVE_DEST** | Rclone remote and path | `gdrive:Pictures` |
| **USB_DEST** | Local backup mount point | `/media/xeno/SAMSUNG/Pictures` |
| **FLAGS** | Performance & UI flags | `--transfers 4 --checkers 8 -P` |

---

## 🛠️ Logic Workflow

1.  **Check Config:** Loads your saved paths automatically.
2.  **Edit Mode:** Prompt to modify settings if your environment changes.
3.  **Sanity Check:** Verifies the source directory exists before starting.
4.  **Target Selection:** Choose between Cloud Drive, Local Drive, or Both.
5.  **Dry Run:** Optional simulation mode to prevent accidental overwrites.

---

## 📝 License
Feel free to fork and modify this script for your own personal backup needs!

> [!IMPORTANT]
> Always verify the **Dry Run** output when changing your common flags to ensure your data is being handled exactly as expected.

Developed by Jack Worthen