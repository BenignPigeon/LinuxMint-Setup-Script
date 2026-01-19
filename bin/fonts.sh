#!/bin/bash

# ----------------------------
# Script: install_extra_fonts.sh
# Purpose: Unattended installation of MS-compatible fonts on Linux Mint
# ----------------------------

set -e

# 1. Root Check
if [[ $EUID -ne 0 ]]; then
   echo "❌ ERROR: Please run this script with sudo."
   exit 1
fi

# 2. Add Repo and IMMEDIATELY Update
echo "🔄 Preparing repositories..."
sudo add-apt-repository -y multiverse
sudo apt update

# 3. Install FontForge and basic tools
echo "🛠 Installing prerequisites..."
sudo apt install -y fontforge wget curl

# 4. Local Fonts Import (Updated for Nested Folders)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd )"
LOCAL_FONTS_DIR="$SCRIPT_DIR/fonts"
DEST_DIR="/usr/local/share/fonts/custom"

if [[ -d "$LOCAL_FONTS_DIR" ]]; then
    echo "📂 Recursively importing local fonts from $LOCAL_FONTS_DIR..."
    mkdir -p "$DEST_DIR"
    
    # Use find to locate all .ttf, .otf, and .ttc files in subfolders and copy them
    # -type f (files only) 
    # -iregex (case-insensitive search for extensions)
    # -exec cp (copy each found file to the destination)
    find "$LOCAL_FONTS_DIR" -type f \( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.ttc" \) -exec cp -v {} "$DEST_DIR" \;

    echo "🔄 Updating font cache..."
    fc-cache -f
else
    echo "⚠️  Note: Local 'fonts' directory not found, skipping local import."
fi

# 5. Install Fonts
echo "🚀 Installing Font Packages..."
sudo apt install -y fonts-roboto fonts-open-sans fonts-lato fonts-montserrat fonts-inter fonts-noto-core fonts-noto-ui-core fonts-dejavu fonts-freefont-ttf

# 6. MS Core Fonts (Unattended)
echo "ttf-mscorefonts-installer ttf-mscorefonts-installer/accepted-mscorefonts-eula select true" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt install -y ttf-mscorefonts-installer fonts-noto fonts-noto-color-emoji

# Final cache refresh
fc-cache -f -v

echo "------------------------------------------------"
echo "✅ SUCCESS: All fonts installed successfully!"
echo "------------------------------------------------"