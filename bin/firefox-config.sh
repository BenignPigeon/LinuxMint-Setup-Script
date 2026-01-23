#!/bin/bash

# 1. Identity & Path Detection
REAL_USER=$(logname)
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
FF_DIR="$USER_HOME/.mozilla/firefox"
INI_FILE="$FF_DIR/profiles.ini"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SRC_PROFILE="$SCRIPT_DIR/firefox/good1.default-release"
PROFILE_NAME="good1.default-release"

# 2. Kill Firefox
pkill -9 firefox 2>/dev/null

# 3. Ensure Directory & Copy
mkdir -p "$FF_DIR"
if [ -d "$SRC_PROFILE" ]; then
    cp -r "$SRC_PROFILE" "$FF_DIR/"
    chown -R "$REAL_USER":"$REAL_USER" "$FF_DIR/$PROFILE_NAME"
else
    echo "Error: Source profile not found."
    exit 1
fi

# 4. Handle profiles.ini Logic
if [ ! -f "$INI_FILE" ]; then
    sudo -u "$REAL_USER" firefox --headless --first-startup &
    sleep 5
    pkill -9 firefox 2>/dev/null
else
    echo "already existed, continuing..."
fi

# Continue install script
rm "$FF_DIR/installs.ini"

echo "Updating existing profiles.ini..."

NEXT_NUM=$(grep -c "^\[Profile" "$INI_FILE")

sed -i '/Default=1/d' "$INI_FILE"

NEW_BLOCK="[Profile$NEXT_NUM]\nName=$PROFILE_NAME\nIsRelative=1\nPath=$PROFILE_NAME\n"

sed -i "/\[General\]/i $NEW_BLOCK" "$INI_FILE"
sed -i "/^\[Install/,/^$/ { s/^Default=.*/Default=$PROFILE_NAME/; s/^Locked=.*/Locked=1/ }" "$INI_FILE"

# If no [Install] block existed but the file did, add a default one at the top
if ! grep -q "^\[Install" "$INI_FILE"; then
    sed -i "1i [Install4F96D1932A9F858E]\nDefault=$PROFILE_NAME\nLocked=1\n" "$INI_FILE"
fi

# 5. Final Permissions Cleanup
rm -f "$FF_DIR/installs.ini"
chown -R "$REAL_USER":"$REAL_USER" "$FF_DIR"

echo "Successfully injected $PROFILE_NAME as Profile$NEXT_NUM"