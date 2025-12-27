#!/bin/bash

# ----------------------------
# Script: install_codecs.sh
# Purpose: Install multimedia codecs if not already installed
# Exits 0 on success, 1 on failure
# ----------------------------

set -e  # Exit immediately on any command failure

# Function to handle errors
error_exit() {
    echo "❌ ERROR: $1"
    exit 1
}

# Check if mint-meta-codecs is installed
if dpkg -s mint-meta-codecs >/dev/null 2>&1; then
    echo "✅ Multimedia codecs are already installed."
else
    echo "💾 Installing multimedia codecs..."
    sudo apt update || error_exit "Failed to update package lists."
    sudo apt install -y mint-meta-codecs || error_exit "Failed to install multimedia codecs."
    echo "✅ Multimedia codecs installed successfully."
fi

exit 0
