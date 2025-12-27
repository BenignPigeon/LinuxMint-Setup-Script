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

# 1. Install Google's Carlito and Caladea (Calibri/Cambria replacements)
echo "📦 Installing Google Carlito and Caladea fonts..."
apt-get update
apt-get install -y fonts-crosextra-carlito fonts-crosextra-caladea

# 2. Install Old Microsoft Fonts (Core Fonts)
echo "📦 Downloading and installing Microsoft Core Fonts..."
# Pre-accept the EULA so the script doesn't hang
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

# Download specific Debian version to avoid extra bloat
wget -q http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.8.1_all.deb -P /tmp

# Install without extra junk
apt-get install -y --no-install-recommends /tmp/ttf-mscorefonts-installer_3.8.1_all.deb

# Safeguard: Copy fonts to local share and purge installer as requested
echo "📂 Moving fonts to local storage and cleaning up installer..."
mkdir -p /usr/local/share/fonts/msttcorefonts2
cp -r /usr/share/fonts/truetype/msttcorefonts/* /usr/local/share/fonts/msttcorefonts2/
apt-get purge -y ttf-mscorefonts-installer
rm /tmp/ttf-mscorefonts-installer_3.8.1_all.deb

# 3. Install Modern Aptos Fonts
echo "📦 Installing Microsoft Aptos fonts..."
APTOS_DIR="/usr/local/share/fonts/truetype/aptos-fonts"
mkdir -p "$APTOS_DIR"

# Download Aptos fonts (using a direct link to the font files)
# Note: Aptos is often bundled in MS archives; we'll use a standard zip source
wget -q https://github.com/vscat-p/aptos-font/archive/refs/heads/main.zip -O /tmp/aptos.zip
apt-get install -y unzip
unzip -oj /tmp/aptos.zip "*.ttf" -d "$APTOS_DIR"
rm /tmp/aptos.zip

# 4. Finalize Font Cache
echo "🔄 Updating system font cache..."
dpkg-reconfigure -f noninteractive fontconfig
fc-cache -fv > /dev/null

echo "------------------------------------------------"
echo "✅ SUCCESS: All fonts installed successfully!"
echo "------------------------------------------------"