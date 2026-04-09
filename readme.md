🚀 Rclone Sync Manager

A lightweight, interactive shell application designed to streamline your backup workflow. Rclone Sync Manager acts as a user-friendly wrapper for rclone, allowing you to manage source directories and destinations (Cloud or Local) without memorizing complex flags every time.
✨ Features

    🎨 Color-Coded Interface: High-visibility terminal output for better readability.

    💾 Persistent Configuration: Saves your paths and flags to ~/.sync_mgr_config so you don't have to re-enter them.

    🔄 Dual-Destination Support: Easily sync to a Cloud remote (Google Drive), a Local drive (USB/External), or both simultaneously.

    🛡️ Safety First: Integrated Dry Run mode to test your sync logic before moving a single byte.

    🛠️ Dynamic Editing: Modify your source, destination, or rclone flags on-the-fly directly within the app.

📋 Prerequisites

Before running the script, ensure you have the following installed:

    Rclone: Install guide here.

    Configured Remote: Ensure your cloud destination (e.g., gdrive) is already configured via rclone config.

🚀 Getting Started
1. Installation

Clone this repository or download the script file:
Bash

chmod +x sync_mgr.sh

2. Usage

Run the script from your terminal:
Bash

./sync_mgr.sh

3. First Run

On the first launch, the script will create a default configuration. You can immediately choose n to modify the Source, Cloud Destination, or Local Path to match your specific hardware and remote setup.
⚙️ Configuration Details

The script manages a hidden config file located at ~/.sync_mgr_config. It tracks:
Variable	Description	Default Example
SOURCE	The local folder you want to back up	/media/xeno/Storage/Pictures
GDRIVE_DEST	Your Rclone remote name and path	gdrive:Pictures
USB_DEST	The mount point of your local backup drive	/media/xeno/SAMSUNG/Pictures
COMMON_FLAGS	Performance and UI flags for Rclone	--transfers 4 --checkers 8 -P
🛠️ Logic Workflow

    Load/Edit: Review current paths; update them if you've swapped USB drives or changed folders.

    Sanity Check: The script verifies the source directory exists before proceeding.

    Target Selection: Choose to sync to Cloud, Local, or Both.

    Dry Run Prompt: Choose whether to perform a simulation or a live sync.

    Execution: Rclone takes over, utilizing the flags you've defined for maximum efficiency.

📝 License

This project is open-source. Feel free to fork, modify, and improve!

    Note: Always double-check your DRY RUN output when changing flags to prevent accidental data loss. Use with care!