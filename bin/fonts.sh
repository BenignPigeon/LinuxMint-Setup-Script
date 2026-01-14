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

sudo add-apt-repository multiverse

echo "🚀 Starting font installation (Unattended Mode)..."

# Install Google Fonts

sudo apt update && sudo apt install fonts-roboto fonts-open-sans fonts-lato fonts-montserrat fonts-inter fonts-noto-core fonts-noto-ui-core fonts-dejavu fonts-freefont-ttf

# Install Microsoft Core Fonts 
echo "ttf-mscorefonts-installer ttf-mscorefonts-installer/accepted-mscorefonts-eula select true" | debconf-set-selections
apt update
DEBIAN_FRONTEND=noninteractive apt install -y ttf-mscorefonts-installer fonts-noto fonts-noto-color-emoji
fc-cache -f

# Install Vista/Office fonts (Calibri, Cambria, Consolas, etc.)
# Check if fontforge is installed
if ! command -v fontforge >/dev/null 2>&1; then
    echo "🛠 FontForge not found. Installing..."
    apt update
    apt install -y fontforge
fi

# Run the Vista fonts installer script
echo "📥 Installing Vista/Office fonts (Calibri, Cambria, Consolas, etc.)..."
wget -q -O - https://gist.githubusercontent.com/Blastoise/72e10b8af5ca359772ee64b6dba33c91/raw/2d7ab3caa27faa61beca9fbf7d3aca6ce9a25916/clearType.sh | bash
wget -q -O - https://gist.githubusercontent.com/Blastoise/b74e06f739610c4a867cf94b27637a56/raw/96926e732a38d3da860624114990121d71c08ea1/tahoma.sh | bash
wget -q -O - https://gist.githubusercontent.com/Blastoise/64ba4acc55047a53b680c1b3072dd985/raw/6bdf69384da4783cc6dafcb51d281cb3ddcb7ca0/segoeUI.sh | bash
wget -q -O - https://gist.githubusercontent.com/Blastoise/d959d3196fb3937b36969013d96740e0/raw/429d8882b7c34e5dbd7b9cbc9d0079de5bd9e3aa/otherFonts.sh | bash




# Final cache refresh
fc-cache -f

echo "------------------------------------------------"
echo "✅ SUCCESS: All fonts installed successfully!"
echo "------------------------------------------------"
