#!/bin/bash

# ----------------------------
# Script: setup_firewall.sh
# Purpose: Enable UFW with sensible defaults for Linux Mint
# ----------------------------

set -e  # Exit on error

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "❌ ERROR: Please run this script with sudo."
   exit 1
fi

echo "🛡️  Configuring Uncomplicated Firewall (UFW)..."

# 1. Install ufw if for some reason it's missing
if ! command -v ufw &> /dev/null; then
    echo "📦 UFW not found. Installing..."
    apt update && apt install -y ufw
fi

# 2. Set Sensible Defaults
# Deny all incoming, Allow all outgoing
echo "⚙️  Setting default policies..."
ufw default deny incoming
ufw default allow outgoing

# 3. Disable Logging (to prevent "spammy" logs as requested)
echo "📝 Disabling firewall logging..."
ufw logging off

# 4. Enable the Firewall
# 'yes |' bypasses the "Command may disrupt existing ssh connections" prompt
echo "🚀 Activating firewall..."
yes | ufw enable

echo "------------------------------------------"
echo "✅ Firewall is now ACTIVE and PROTECTING your system."
echo "------------------------------------------"

# 5. Display Status
ufw status verbose

exit 0