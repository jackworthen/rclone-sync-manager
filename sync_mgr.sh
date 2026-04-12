#!/bin/bash
clear

# --- Configuration Setup ---
CONFIG_FILE="$HOME/.sync_mgr_config"

save_config() {
    cat <<EOF > "$CONFIG_FILE"
SOURCE="$SOURCE"
GDRIVE_DEST="$GDRIVE_DEST"
USB_DEST="$USB_DEST"
COMMON_FLAGS=($(printf "'%s' " "${COMMON_FLAGS[@]}"))
EOF
}

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
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
RED='\033[0;31m'
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

    # Input Validation: Use current config?
    while true; do
        read -p "Use current configuration? (y/n): " USE_CONFIG
        case $USE_CONFIG in
            [Yy]* ) break 2 ;; # Break out of both loops
            [Nn]* ) break ;;   # Break out of this inner loop to modify
            * ) echo -e "${RED}Invalid input. Please enter 'y' or 'n'.${NC}" ;;
        esac
    done

    while true; do
        echo -e "\nWhich configuration would you like to modify?"
        echo "1) Source"
        echo "2) Cloud Drive"
        echo "3) Local Drive"
        echo "4) Flags"
        echo "5) Cancel"
        echo
        read -p "Select an option [1-5]: " MOD_CHOICE

        case $MOD_CHOICE in
            1) read -p "Enter new Source: " SOURCE; break ;;
            2) read -p "Enter new GDrive Destination: " GDRIVE_DEST; break ;;
            3) read -p "Enter new USB Destination: " USB_DEST; break ;;
            4) read -p "Enter new Common Flags (space separated): " -a COMMON_FLAGS; break ;;
            5) echo -e "${YELLOW}Modification cancelled.${NC}"; break ;;
            *) echo -e "${RED}Invalid selection. Please choose 1-5.${NC}" ;;
        esac
    done

    if [[ "$MOD_CHOICE" =~ ^[1-4]$ ]]; then
        save_config
        echo -e "${GREEN}Configuration updated and saved.${NC}"
    fi
    echo ""
done

# --- Sanity Checks ---
if [ ! -d "$SOURCE" ]; then
    echo -e "${RED}Error: Source directory '$SOURCE' does not exist!${NC}"
    exit 1
fi

# 1. Select Destination with Validation
while true; do
    echo -e "\nWhere would you like to sync?"
    echo "1) Cloud Drive"
    echo "2) Local Drive"
    echo "3) Both"
    echo
    read -p "Select an option [1-3]: " DEST_CHOICE
    case $DEST_CHOICE in
        [1-3] ) break ;;
        * ) echo -e "${RED}Invalid selection. Please choose 1, 2, or 3.${NC}" ;;
    esac
done

# 2. Select Run Mode with Validation
while true; do
    read -p "Perform a dry run first? (y/n): " DRY_RUN_INPUT
    case $DRY_RUN_INPUT in
        [Yy]* ) 
            DRY_RUN_FLAG=("--dry-run")
            echo -e "\n${YELLOW}--- DRY RUN ENABLED (No files will be copied) ---${NC}"
            break ;;
        [Nn]* ) 
            DRY_RUN_FLAG=()
            break ;;
        * ) echo -e "${RED}Invalid input. Please enter 'y' or 'n'.${NC}" ;;
    esac
done

# Function to execute sync
do_sync() {
    local DEST=$1
    local LABEL=$2
    echo -e "\nStarting sync to ${BLUE}$LABEL${NC}..."
    rclone copy "$SOURCE" "$DEST" "${COMMON_FLAGS[@]}" "${DRY_RUN_FLAG[@]}"
    echo -e "\n${GREEN}Finished sync to $LABEL.${NC}"
}

# 3. Execution Logic
case $DEST_CHOICE in
    1) do_sync "$GDRIVE_DEST" "Cloud Drive" ;;
    2) do_sync "$USB_DEST" "Local Drive" ;;
    3) 
        do_sync "$GDRIVE_DEST" "Cloud Drive"
        do_sync "$USB_DEST" "Local Drive"
        ;;
esac

echo -e "\n${GREEN}Process Complete.${NC}"
