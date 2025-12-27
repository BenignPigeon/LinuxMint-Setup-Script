#!/bin/bash

# ---------------------------------------------------------
# Script: optimize_laptop_ui.sh
# Purpose: Auto-scale UI for 13-15" Laptop Screens (Cinnamon)
# ---------------------------------------------------------

# 1. System-wide installs (Requires sudo)
if [[ $EUID -ne 0 ]]; then
   echo "❌ ERROR: Please run this script with sudo."
   exit 1
fi

echo "📦 Installing HiDPI Grub theme and Classic Ubuntu fonts..."
apt-get update
apt-get install -y grub2-theme-mint-2k fonts-ubuntu-classic

# ---------------------------------------------------------
# 2. User-specific settings (Must run as the logged-in user)
# We use 'sudo -u' to target the actual user account
# ---------------------------------------------------------
TARGET_USER=$(logname)

echo "🖥️  Applying UI scaling for user: $TARGET_USER"

# A. Increase Text Scaling (1.2 is the "sweet spot" for 13-15" screens)
sudo -u $TARGET_USER gsettings set org.cinnamon.desktop.interface text-scaling-factor 1.2

# B. Set Mouse Pointer Size (Standard is 24, we'll bump to 32 or 48)
sudo -u $TARGET_USER gsettings set org.cinnamon.desktop.interface cursor-size 32

# C. Panel Height and Icon Sizes
# Note: Mint stores panel settings in a slightly more complex way. 
# This command targets the bottom panel (panel 1).
echo "📏 Adjusting Panel height and icon zones..."
sudo -u $TARGET_USER gsettings set org.cinnamon panels-height "['1:45']"
sudo -u $TARGET_USER gsettings set org.cinnamon panels-icons-sizes "['1:28:28:32']"

# D. Desktop Icon Size
echo "📁 Increasing Desktop icon size..."
sudo -u $TARGET_USER gsettings set org.nemo.desktop icon-view-grid-adjust 1.2
sudo -u $TARGET_USER gsettings set org.nemo.icon-view default-zoom-level 'large'

echo "------------------------------------------------"
echo "✅ UI Optimization Complete!"
echo "⚠️  MANDATORY: Please REBOOT now to fix font rendering."
echo "------------------------------------------------"