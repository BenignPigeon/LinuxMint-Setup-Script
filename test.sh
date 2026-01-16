#!/bin/bash

# Colors for terminal output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Check if an argument was provided
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage:${NC} $0 <script-to-test>"
    exit 1
fi

SCRIPT="$1"

# Prompt for sudo upfront
echo -e "${BLUE}Requesting sudo privileges...${NC}"
sudo -v

# Run the script
echo -e "${BLUE}Running $SCRIPT...${NC}"
if sudo bash "$SCRIPT"; then
    echo -e "${GREEN}✅ Success: $SCRIPT completed without errors!${NC}"
else
    echo -e "${RED}❌ Failed: $SCRIPT exited with errors.${NC}"
fi
