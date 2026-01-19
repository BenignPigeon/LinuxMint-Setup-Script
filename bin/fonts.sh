#!/bin/bash

# ----------------------------
# Script: install_extra_fonts.sh
# Purpose: Unattended installation of MS-compatible fonts on Linux Mint
# ----------------------------

#!/bin/bash

set -e

# 1. Root Check
if [[ $EUID -ne 0 ]]; then
   echo "❌ ERROR: Please run this script with sudo."
   exit 1
fi

# 2. Add Repo and IMMEDIATELY Update
echo "🔄 Preparing repositories..."
sudo add-apt-repository -y multiverse
sudo apt update  # This is the "refresh" you need

# 3. Install FontForge and basic tools first
# Added -y to ensure it doesn't hang
echo "🛠 Installing prerequisites..."
sudo apt install -y fontforge wget curl

# 4. Local Fonts Import
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd )"
LOCAL_FONTS_DIR="$SCRIPT_DIR/fonts"

if [[ -d "$LOCAL_FONTS_DIR" ]]; then
    echo "📂 Importing local fonts..."
    mkdir -p /usr/local/share/fonts/custom
    cp -v "$LOCAL_FONTS_DIR"/*.{ttf,otf,ttc} /usr/local/share/fonts/custom/ 2>/dev/null || true
    fc-cache -f
fi

# 5. Install Fonts (Added -y flag)
echo "🚀 Installing Font Packages..."
sudo apt install -y fonts-roboto fonts-open-sans fonts-lato fonts-montserrat fonts-inter fonts-noto-core fonts-noto-ui-core fonts-dejavu fonts-freefont-ttf

# 6. MS Core Fonts (Unattended)
echo "ttf-mscorefonts-installer ttf-mscorefonts-installer/accepted-mscorefonts-eula select true" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt install -y ttf-mscorefonts-installer fonts-noto fonts-noto-color-emoji

# 7. Vista Fonts (The External Scripts)
echo "📥 Installing Vista/Office fonts..."
# Run the Vista fonts installer script
echo "📥 Installing Vista/Office fonts (Calibri, Cambria, Consolas, etc.)..."
curl -sL https://gist.githubusercontent.com/Blastoise/72e10b8af5ca359772ee64b6dba33c91/raw/2d7ab3caa27faa61beca9fbf7d3aca6ce9a25916/clearType.sh | bash
curl -sL https://gist.githubusercontent.com/Blastoise/b74e06f739610c4a867cf94b27637a56/raw/96926e732a38d3da860624114990121d71c08ea1/tahoma.sh | bash
curl -sL https://gist.githubusercontent.com/Blastoise/64ba4acc55047a53b680c1b3072dd985/raw/6bdf69384da4783cc6dafcb51d281cb3ddcb7ca0/segoeUI.sh | bash
curl -sL https://gist.githubusercontent.com/Blastoise/d959d3196fb3937b36969013d96740e0/raw/429d8882b7c34e5dbd7b9cbc9d0079de5bd9e3aa/otherFonts.sh | bash

# Final cache refresh
fc-cache -f -v

echo "------------------------------------------------"
echo "✅ SUCCESS: All fonts installed successfully!"
echo "------------------------------------------------"
