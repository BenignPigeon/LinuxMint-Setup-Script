#!/usr/bin/env bash

# 1. Path Anchoring
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Self-Elevation 
if [[ $EUID -ne 0 ]]; then
    echo -e "${CYAN}🔐 Requesting administrative privileges...${NC}"
    # This finds the absolute path so it never gets lost
    SCRIPT_PATH=$(readlink -f "$0")
    exec sudo bash "$SCRIPT_PATH" "$@"
fi

# 2. Define Jobs: "Display Name | Script Path"
JOBS=(
    "System Update and Backup|bin/backup1.sh"
)

# Color Palette
BG_BLUE='\033[44m'; BG_MAGENTA='\033[45m'; BG_GREEN='\033[42m'; BG_RED='\033[41m'
FG_BLACK='\033[30m'; CYAN='\033[0;36m'; BLUE='\033[0;34m'; GREEN='\033[0;32m'
RED='\033[0;31m'; BOLD='\033[1m'; DIM='\033[2m'; YELLOW='\033[1;33m'; NC='\033[0m'

# Icons
ICON_GEAR="⚙"; ICON_CHECK="✔"; ICON_CROSS="✖"; ICON_ARROW="❯"; ICON_WARN="⚠️"

# --- NEW: OS Check Section ---
check_os() {
    # Check if the OS ID is 'linuxmint'
    if grep -q "ID=linuxmint" /etc/os-release; then
        return 0
    fi

    clear
    echo -e "${BG_RED}${FG_BLACK}${BOLD} COMPATIBILITY WARNING ${NC}"
    echo -e "${CYAN}${DIM}──────────────────────────────────────────────────${NC}"
    echo -e "  ${YELLOW}${ICON_WARN}${NC} ${BOLD} CAUTION:${NC} This script is optimized for ${BOLD}Linux Mint${NC}."
    echo -e "  Running it on a different distro may cause ${RED}massive errors${NC}."
    echo
    echo -en "  Do you want to continue anyway? (y/n): "
    read -r choice
    
    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        echo -e "\n  ${DIM}Exiting to prevent system damage.${NC}\n"
        exit 1
    fi
}

# Run the OS check before doing anything else
check_os
# -----------------------------

TOTAL=${#JOBS[@]}
COMPLETED=()
FAIL_COUNT=0

run_script() {
    local index=$1
    local entry=$2
    local display_name="${entry%%|*}"
    local script_rel_path="${entry##*|}"
    local step="$((index + 1))/$TOTAL"
    local full_path="$SCRIPT_DIR/$script_rel_path"

    clear
    echo -e "${BG_BLUE}${FG_BLACK}${BOLD} LINUX AUTOMATION TOOL ${NC}${BG_MAGENTA}${FG_BLACK} ${step} ${NC}"
    echo -e "${CYAN}${DIM}──────────────────────────────────────────────────${NC}"
    echo

    if [ ${#COMPLETED[@]} -gt 0 ]; then
        for item in "${COMPLETED[@]}"; do
            echo -e "  $item"
        done
        echo -e "${CYAN}${DIM}  ────────────────────────────────────────────────${NC}"
        echo
    fi

    echo -e "  ${BLUE}${ICON_GEAR}${NC} ${BOLD}CURRENTLY RUNNING:${NC}"
    echo -e "  ${ICON_ARROW} ${DIM}[${step}]${NC} ${CYAN}${display_name}${NC}"
    echo -e "    ${DIM}Path: $script_rel_path${NC}"
    echo


    echo -e "  ${DIM}┌── Output ────────────────────────────────────┐${NC}"
    if [ -f "$full_path" ]; then
        bash "$full_path" 2>&1 | sed 's/^/  │ /'
        status=${PIPESTATUS[0]}
    else
        echo -e "  │ ${RED}Error: File not found at ${full_path}${NC}"
        status=1
    fi
    echo -e "  ${DIM}└──────────────────────────────────────────────┘${NC}"

    if [ $status -eq 0 ]; then
        COMPLETED+=("${GREEN}${ICON_CHECK}${NC} ${DIM}[${step}]${NC} ${display_name}")
    else
        COMPLETED+=("${RED}${ICON_CROSS}${NC} ${DIM}[${step}]${NC} ${display_name} ${RED}(failed)${NC}")
        ((FAIL_COUNT++))
    fi
}

for i in "${!JOBS[@]}"; do
    run_script "$i" "${JOBS[$i]}"
done

clear
echo -e "${BG_BLUE}${FG_BLACK}${BOLD} TASK COMPLETE ${NC}"
echo -e "${CYAN}${DIM}──────────────────────────────────────────────────${NC}"
echo
for item in "${COMPLETED[@]}"; do
    echo -e "  $item"
done
echo

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "  ${BG_GREEN}${FG_BLACK}${BOLD} SUCCESS ${NC} All scripts executed perfectly."
else
    echo -e "  ${BG_RED}${FG_BLACK}${BOLD} WARNING ${NC} Finished with ${RED}${FAIL_COUNT}${NC} error(s)."
fi
echo