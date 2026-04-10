#!/bin/bash
clear

# --- Configuration Setup ---
# Storing the config in the home directory to avoid permission issues in /usr/local/bin
CONFIG_FILE="$HOME/.sync_mgr_config"

# Function to save current variables to the config file
save_config() {
    cat <<EOF > "$CONFIG_FILE"
SOURCE="$SOURCE"
GDRIVE_DEST="$GDRIVE_DEST"
USB_DEST="$USB_DEST"
COMMON_FLAGS=($(printf "'%s' " "${COMMON_FLAGS[@]}"))
EOF
}

# Load existing config or set defaults
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    # Default values if no config exists
    SOURCE="/media/xeno/Storage/Pictures"
    GDRIVE_DEST="gdrive:Pictures"
    USB_DEST="/media/xeno/SAMSUNG/Pictures"
    COMMON_FLAGS=("--transfers" "4" "--checkers" "8" "-P")
    save_config
fi

# Color Codes
ORANGE='\033[0;33m'
BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Banner ---
echo -e "${ORANGE}---------------------------------------${NC}"
echo -e "${ORANGE}      RCLONE SYNC MANAGER v1.1         ${NC}"
echo -e "${ORANGE}---------------------------------------${NC}"

while true; do
    # --- Configuration Summary Display ---
    echo -e "${GREEN}Current Configuration:${NC}"
    echo -e "  Config File:    ${YELLOW}$CONFIG_FILE${NC}"
    echo -e "  Source:         ${BLUE}$SOURCE${NC}"
    echo -e "  Cloud Drive:    ${BLUE}$GDRIVE_DEST${NC}"
    echo -e "  Local Drive:    ${BLUE}$USB_DEST${NC}"
    echo -e "  Flags:          ${YELLOW}${COMMON_FLAGS[*]}${NC}"
    echo -e "${ORANGE}---------------------------------------${NC}"
    echo ""

    read -p "Use current configuration? (y/n): " USE_CONFIG
    if [[ "$USE_CONFIG" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        break
    fi

    echo -e "\nWhich configuration would you like to modify?"
    echo "1) Source"
    echo "2) Cloud Drive"
    echo "3) Local Drive"
    echo "4) Flags"
    echo "5) Cancel"
    echo
    read -p "Select an option [1-5]: " MOD_CHOICE

    case $MOD_CHOICE in
        1) read -p "Enter new Source: " SOURCE ;;
        2) read -p "Enter new GDrive Destination: " GDRIVE_DEST ;;
        3) read -p "Enter new USB Destination: " USB_DEST ;;
        4) read -p "Enter new Common Flags (space separated): " -a COMMON_FLAGS ;;
        5) echo -e "${YELLOW}Modification cancelled.${NC}" ;;
        *) echo -e "${ORANGE}Invalid option. Please try again.${NC}" ;;
    esac

    # Save changes immediately if a modification was made
    if [[ "$MOD_CHOICE" =~ ^[1-4]$ ]]; then
        save_config
        echo -e "${GREEN}Configuration updated and saved to $CONFIG_FILE.${NC}"
    fi
    echo ""
done

# --- Sanity Checks ---
if [ ! -d "$SOURCE" ]; then
    echo -e "${ORANGE}Error: Source directory '$SOURCE' does not exist!${NC}"
    exit 1
fi

# 1. Select Destination
echo
echo "Where would you like to sync?"
echo "1) Cloud Drive"
echo "2) Local Drive"
echo "3) Both"
echo
read -p "Select an option [1-3]: " DEST_CHOICE

# 2. Select Run Mode
echo
read -p "Perform a dry run first? (y/n): " DRY_RUN_INPUT

DRY_RUN_FLAG=()
if [[ "$DRY_RUN_INPUT" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    DRY_RUN_FLAG=("--dry-run")
    echo -e "\n${YELLOW}--- DRY RUN ENABLED (No files will be copied) ---${NC}"
fi

# Function to execute sync
do_sync() {
    local DEST=$1
    local LABEL=$2
    echo -e "\nStarting sync to ${BLUE}$LABEL${NC}..."
    
    rclone copy "$SOURCE" "$DEST" "${COMMON_FLAGS[@]}" "${DRY_RUN_FLAG[@]}"

    echo -e "\n${GREEN}Finished sync to $LABEL.${NC}"
    echo -e "${ORANGE}---------------------------------------${NC}"
}

# 3. Execution Logic
case $DEST_CHOICE in
    1)
        do_sync "$GDRIVE_DEST" "Cloud Drive"
        ;;
    2)
        do_sync "$USB_DEST" "Local Drive"
        ;;
    3)
        do_sync "$GDRIVE_DEST" "Cloud Drive"
        do_sync "$USB_DEST" "Local Drive"
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac

echo -e "${GREEN}Process Complete.${NC}"
