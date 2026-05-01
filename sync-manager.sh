#!/bin/bash
clear

# --- Configuration Setup ---
PROFILES_DIR="$HOME/.sync_mgr_profiles"
mkdir -p "$PROFILES_DIR"

save_config() {
    local PROFILE_NAME="$1"
    local FILE_PATH="$PROFILES_DIR/${PROFILE_NAME}.conf"
    cat <<EOF > "$FILE_PATH"
SOURCE="$SOURCE"
GDRIVE_DEST="$GDRIVE_DEST"
USB_DEST="$USB_DEST"
COMMON_FLAGS=($(printf "'%s' " "${COMMON_FLAGS[@]}"))
EOF
}

list_profiles() {
    (cd "$PROFILES_DIR" && for f in *.conf; do [ -e "$f" ] && echo "${f%.conf}"; done)
}

# Color Codes
ORANGE='\033[0;33m'
BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Banner ---
echo ""
echo -e "   ${BLUE}▟████▙${NC}     ${ORANGE}RCLONE SYNC MANAGER ${YELLOW}v2.0${NC}"
echo -e "   ${BLUE}██▛▀▀▀${NC}"
echo -e "   ${GREEN}▜████▙${NC}     ${GREEN}Effortless harmony between cloud and core.${NC}"
echo -e "   ${YELLOW}▄▄▄▜██${NC}     ${BLUE}Profiles directory: ${PROFILES_DIR}${NC}"
echo -e "   ${RED}▜████▛${NC}"
echo ""

# --- Profile Selection & Creation ---
while true; do
    PROFILES=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && PROFILES+=("$line")
    done < <(list_profiles)
    
    # Ensure "Pictures" profile exists if no profiles at all
    if [ ${#PROFILES[@]} -eq 0 ]; then
        OLD_CONFIG="$HOME/.sync_mgr_config"
        if [ -f "$OLD_CONFIG" ]; then
            source "$OLD_CONFIG"
            CURRENT_PROFILE="Pictures"
            save_config "$CURRENT_PROFILE"
        else
            SOURCE="/media/xeno/Storage/Pictures"
            GDRIVE_DEST="gdrive:Pictures"
            USB_DEST="/media/xeno/SAMSUNG/Pictures"
            COMMON_FLAGS=("--transfers" "4" "--checkers" "8" "-P")
            CURRENT_PROFILE="Pictures"
            save_config "$CURRENT_PROFILE"
        fi
        PROFILES=("Pictures")
    fi

    echo "1) Use an existing profile"
    echo "2) Create a new profile"
    echo "3) Exit"
    echo
    read -p "Select an option [1-3]: " START_CHOICE

    case $START_CHOICE in
        1)
            echo -e "\n${BLUE}Available Profiles:${NC}"
            for i in "${!PROFILES[@]}"; do
                echo "$((i+1))) ${PROFILES[$i]}"
            done
            echo ""
            read -p "Select a profile [1-${#PROFILES[@]}]: " PROF_CHOICE
            if [[ "$PROF_CHOICE" -gt 0 && "$PROF_CHOICE" -le "${#PROFILES[@]}" ]]; then
                CURRENT_PROFILE="${PROFILES[$((PROF_CHOICE-1))]}"
                source "$PROFILES_DIR/${CURRENT_PROFILE}.conf"
                break
            else
                echo -e "${RED}Invalid selection.${NC}"
            fi
            ;;
        2)
            read -p "Enter name for new profile: " NEW_PROF_NAME
            if [[ -z "$NEW_PROF_NAME" ]]; then
                echo -e "${RED}Profile name cannot be empty.${NC}"
                continue
            fi
            read -p "Enter Source Path: " SOURCE
            read -p "Enter Cloud Drive Destination (e.g., gdrive:Path): " GDRIVE_DEST
            read -p "Enter Local Drive Destination: " USB_DEST
            read -p "Enter Common Flags (space separated, default: -P): " FLAGS_INPUT
            if [[ -z "$FLAGS_INPUT" ]]; then
                COMMON_FLAGS=("-P")
            else
                read -a COMMON_FLAGS <<< "$FLAGS_INPUT"
            fi
            CURRENT_PROFILE="$NEW_PROF_NAME"
            save_config "$CURRENT_PROFILE"
            echo -e "${GREEN}Profile '$CURRENT_PROFILE' created.${NC}"
            break
            ;;
        3) exit 0 ;;
        *) echo -e "${RED}Invalid selection.${NC}" ;;
    esac
done

# --- Configuration Summary Display ---
echo -e "\n${ORANGE}---------------------------------------${NC}"
echo -e "      Profile: ${YELLOW}$CURRENT_PROFILE${NC}"
echo -e "${ORANGE}---------------------------------------${NC}"
echo -e "${GREEN}Current Configuration:${NC}"
echo -e "  Source:         ${BLUE}$SOURCE${NC}"
echo -e "  Cloud Drive:    ${BLUE}$GDRIVE_DEST${NC}"
echo -e "  Local Drive:    ${BLUE}$USB_DEST${NC}"
echo -e "  Flags:          ${YELLOW}${COMMON_FLAGS[*]}${NC}"
echo -e "${ORANGE}---------------------------------------${NC}"

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

echo ""

# 2. Select Run Mode with Validation
while true; do
    read -p "Perform a dry run first? (y/n): " DRY_RUN_INPUT
    case $DRY_RUN_INPUT in
        [Yy]* ) 
            DRY_RUN_FLAG=("--dry-run")
            echo -e "\n${RED}--- DRY RUN ENABLED (No files will be copied) ---${NC}"
            IS_DRY_RUN=true
            break ;;
        [Nn]* ) 
            DRY_RUN_FLAG=()
            IS_DRY_RUN=false
            break ;;
        * ) echo -e "${RED}Invalid input. Please enter 'y' or 'n'.${NC}" ;;
    esac
done

# Function to execute sync
do_sync() {
    local DEST=$1
    local LABEL=$2
    shift 2
    local FLAGS=("$@")
    echo -e "\nStarting sync to ${BLUE}$LABEL${NC}..."
    rclone copy "$SOURCE" "$DEST" "${COMMON_FLAGS[@]}" "${FLAGS[@]}" --stats 0
    echo -e "\n${GREEN}Finished sync to $LABEL.${NC}"
}

# 3. Execution Logic
run_transfer() {
    local TARGET_FLAGS=("$@")
    case $DEST_CHOICE in
        1) do_sync "$GDRIVE_DEST" "Cloud Drive" "${TARGET_FLAGS[@]}" ;;
        2) do_sync "$USB_DEST" "Local Drive" "${TARGET_FLAGS[@]}" ;;
        3) 
            do_sync "$GDRIVE_DEST" "Cloud Drive" "${TARGET_FLAGS[@]}"
            do_sync "$USB_DEST" "Local Drive" "${TARGET_FLAGS[@]}"
            ;;
    esac
}

# Execute initial run (Dry Run or Actual)
run_transfer "${DRY_RUN_FLAG[@]}"

# If it was a dry run, ask to proceed with actual transfer
if [ "$IS_DRY_RUN" = true ]; then
    echo ""
    while true; do
        echo -en "${ORANGE}Dry run complete. Would you like to proceed with the ACTUAL transfer? ${YELLOW}(y/n)${NC}: "
        read PROCEED_INPUT
        case $PROCEED_INPUT in
            [Yy]* )
                echo -e "\n${YELLOW}--- STARTING ACTUAL TRANSFER ---${NC}"
                run_transfer
                break ;;
            [Nn]* )
                echo -e "\n${YELLOW}Transfer cancelled by user.${NC}"
                break ;;
            * ) echo -e "${RED}Invalid input. Please enter 'y' or 'n'.${NC}" ;;
        esac
    done
fi

echo -e "\n${GREEN}Process Complete.${NC}"
