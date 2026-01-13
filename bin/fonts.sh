#!/bin/bash

# ----------------------------
# Script: install_extra_fonts.sh
# Purpose: Unattended installation of MS-compatible fonts on Linux Mint
# ----------------------------

set -e

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "❌ ERROR: Please run this script with sudo."
   exit 1
fi

echo "🚀 Starting font installation (Unattended Mode)..."

echo "ttf-mscorefonts-installer ttf-mscorefonts-installer/accepted-mscorefonts-eula select true" | sudo debconf-set-selections && sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt install -y ttf-mscorefonts-installer fonts-noto fonts-noto-color-emoji && sudo fc-cache -f

echo "------------------------------------------------"
echo "✅ SUCCESS: All fonts installed successfully!"
echo "------------------------------------------------"