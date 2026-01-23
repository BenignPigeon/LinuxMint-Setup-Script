#!/bin/bash

# ----------------------------------------------------------------
# Script: setup_configs.sh
# Purpose: Sync ./bin/config to ~/.config/ and fix permissions
# ----------------------------------------------------------------

# 0. Ensure the script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo "❌ ERROR: This script must be run with sudo."
   exit 1
fi

# ================================================================
# CONFIGURATION: ADD MORE APPS HERE
# ================================================================
# Add the process names (what you see in 'pgrep' or 'top') to this list.
# Example: APPS_TO_CLOSE=("soffice.bin" "albert" "firefox" "discord")
APPS_TO_CLOSE=(
    "soffice.bin"   # LibreOffice
    "albert"        # Albert Launcher
)
# ================================================================

# 1. Close active instances of apps in the list
echo "📨 Checking for active applications..."
for APP in "${APPS_TO_CLOSE[@]}"; do
    if pgrep -x "$APP" > /dev/null; then
        echo "   -> Closing $APP..."
        pkill -u "$SUDO_USER" -x "$APP" || true
        NEED_SLEEP=true
    fi
done

# Give the system a moment to release file locks only if we actually closed something
if [ "$NEED_SLEEP" = true ]; then
    sleep 2
fi

# 2. Identify the actual user (not root)
REAL_USER=$SUDO_USER
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
TARGET_CONFIG_DIR="$USER_HOME/.config"

# 3. Define the source directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd )"
SOURCE_CONFIG_DIR="$SCRIPT_DIR/config"

echo "🚀 Starting configuration sync for user: $REAL_USER"

# 4. Check if source directory exists
if [ ! -d "$SOURCE_CONFIG_DIR" ]; then
    echo "❌ ERROR: Source directory $SOURCE_CONFIG_DIR not found!"
    exit 1
fi

# 5. Copy folders
# We loop through each item in ./bin/config/ to replace folders individually
for item in "$SOURCE_CONFIG_DIR"/*; do
    if [ -d "$item" ]; then
        folder_name=$(basename "$item")
        echo "📂 Syncing: $folder_name"
        
        # Remove existing folder in .config to ensure a clean replacement
        rm -rf "$TARGET_CONFIG_DIR/$folder_name"
        
        # Copy the new folder
        cp -r "$item" "$TARGET_CONFIG_DIR/"
    fi
done

# 6. Alter Albert Contents
ALBERT_CONFIG="$TARGET_CONFIG_DIR/albert/config"

if [ -f "$ALBERT_CONFIG" ]; then
    echo "✏️ Updating Albert config..."

    # Prepare the block with correct paths (no backslashes)
    ALBERT_BLOCK=$(cat <<EOM
enabled=true
home/$REAL_USER/followSymlinks=false
home/$REAL_USER/indexhidden=false
home/$REAL_USER/maxDepth=255
home/$REAL_USER/mimeFilters=inode/directory, image/*, video/*, audio/*, inode/*, application/*, message/*, model/*, multipart/*, text/*, x-content/*, x-epoc/*
home/$REAL_USER/nameFilters=@Invalid()
home/$REAL_USER/scanInterval=5
home/$REAL_USER/useFileSystemWatches=false
paths=$USER_HOME
EOM
)
    # Insert the block after the [files] section (case-insensitive)
    awk -v block="$ALBERT_BLOCK" 'BEGIN{IGNORECASE=1} /^\[files\]/{print; print block; next} {print}' "$ALBERT_CONFIG" > "$ALBERT_CONFIG.tmp" \
        && mv "$ALBERT_CONFIG.tmp" "$ALBERT_CONFIG"

    echo "✅ Albert config updated successfully."
else
    echo "⚠️ Albert config not found at $ALBERT_CONFIG, skipping..."
fi


# 7. Fix Permissions
echo "🔧 Adjusting permissions for $REAL_USER..."
chown -R "$REAL_USER:$REAL_USER" "$TARGET_CONFIG_DIR"

echo "------------------------------------------------"
echo "✅ SUCCESS: Configs updated in $TARGET_CONFIG_DIR"
echo "------------------------------------------------"