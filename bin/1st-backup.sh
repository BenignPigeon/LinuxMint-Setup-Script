#!/bin/bash

# ----------------------------
# Script: update_and_backup.sh
# Purpose: Apply updates and create a Timeshift snapshot safely
# ----------------------------

# Exit on error
set -e

# --- 0. Pre-Flight Checks ---

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script with sudo: sudo $0"
    exit 1
fi

error_exit() {
    echo "❌ ERROR: $1" >&2
    exit 1
}

# Check if another update process is running (prevents lock errors)
echo "🔍 Checking for system locks..."
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "⏳ Waiting for other update processes to finish..."
    sleep 5
done

# --- 1. Apply Updates ---

echo "🔄 Updating package lists..."
apt update || error_exit "Failed to update package lists."

echo "⬆️ Upgrading packages (Keeping existing configs)..."
# We use DEBIAN_FRONTEND=noninteractive to ensure it doesn't hang on prompts
export DEBIAN_FRONTEND=noninteractive
apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade -y || error_exit "Package upgrade failed."

echo "🔧 Running full-upgrade..."
apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" full-upgrade -y || error_exit "Full upgrade failed."

echo "🧹 Cleaning up old packages..."
apt autoremove -y && apt autoclean -y

# --- 2. Timeshift Validation ---

if ! command -v timeshift >/dev/null 2>&1; then
    echo "💾 Installing Timeshift..."
    apt install -y timeshift || error_exit "Failed to install Timeshift."
fi

if [ ! -f /etc/timeshift/timeshift.json ]; then
    error_exit "Timeshift is not configured. Please open 'Timeshift' from the Menu and select a backup drive first."
fi

# --- 3. Create Snapshot ---

echo "📦 Creating Timeshift snapshot: 'Original State'..."
# Tags: O = On-demand (standard for manual snapshots)
timeshift --create --comments "Original State" --tags O || error_exit "Failed to create snapshot. Is the backup drive plugged in?"

echo "✅ System updated and snapshot created successfully."
exit 0