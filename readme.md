# 🚀 Rclone Sync Manager v2.1

A professional, interactive shell application designed to streamline your backup workflow. **Rclone Sync Manager** acts as a user-friendly wrapper for `rclone`, allowing you to manage multiple sync profiles for different directories and destinations without memorizing complex flags.

---

## ✨ Features

* **🗂️ Profile-Based Management:** Create, save, edit, and delete unique profiles (e.g., Pictures, Documents, Work) for different sync tasks.
* **📊 Status Tracking:** View the last run timestamp and success/failure status of each profile directly in the selection menu.
* **🎨 Gemini-Inspired UI:** A modern, minimalist interface with a professional logo, vertical alignment, and color-coded feedback.
* **💾 Automatic Migration:** Seamlessly upgrades your legacy single-config setup to the new profile system on first run.
* **🔄 Dual-Destination Support:** Sync to Cloud (e.g., Google Drive), Local (e.g., USB), or both.
* **🛡️ Interactive Dry Run:** Integrated safety mode that allows you to verify your sync and then immediately kick off the actual transfer if satisfied.
* **📈 Optimized Output:** Clean, non-redundant rclone statistics for better readability during execution.

---

## 📋 Prerequisites

Before running the script, ensure you have:
1.  **Rclone installed** (`rclone --version`).
2.  **A configured remote** (e.g., `gdrive`) via `rclone config`.

---

## 🚀 Getting Started

### 1. Installation
Clone the repository and make the script executable:
```bash
git clone https://github.com/jackworthen/rclone-sync-manager
cd rclone-sync-manager
chmod +x sync-manager.sh
```

### 2. Usage
Run the script from your terminal:
```bash
./sync-manager.sh
```

---

## ⚙️ Configuration

Profiles are stored as individual `.conf` files in a hidden directory: `~/.sync_mgr_profiles/`.

| Field | Description |
| :--- | :--- |
| **Profile Name** | A unique label for your sync task (e.g., `Work_Backups`). |
| **SOURCE** | The local folder you wish to back up. |
| **GDRIVE_DEST** | Your Rclone remote name and path (e.g., `gdrive:Backups`). |
| **USB_DEST** | Your local backup mount point or drive path. |
| **FLAGS** | Performance and UI flags passed directly to rclone. |

---

## 🛠️ Logic Workflow

1.  **Banner & Setup:** Displays the professional v2.0 banner and ensures the profiles directory exists.
2.  **Profile Selection:** Choose an existing profile, create a new one, or **manage (edit/delete)** existing profiles.
3.  **Summary:** Displays the active configuration for the selected profile before proceeding.
4.  **Target Selection:** Choose to sync to Cloud Drive, Local Drive, or Both.
5.  **Interactive Dry Run:**
    * Performs a simulation of the sync.
    * If successful, prompts you to immediately start the **ACTUAL** transfer without restarting.

---

## 📝 License
This project is licensed under GNU GENERAL PUBLIC LICENSE - see the LICENSE file for details.

Developed by [Jack Worthen](https://github.com/jackworthen)
