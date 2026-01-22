#!/bin/bash

# 1. Identity & Path Detection
REAL_USER=$(logname)
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
FF_DIR="$USER_HOME/.mozilla/firefox"

# Get absolute path of this script to find the profile folder
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SRC_PROFILE="$SCRIPT_DIR/firefox/good1.default-release"
PROFILE_NAME="good1.default-release"

# 2. NON-SUICIDAL PKILL
echo "Killing Firefox..."
pkill -9 firefox
echo "Killed firefox, nice"

# 3. The Wait
echo "Process handled. Waiting 5s for sync..."
sleep 5

# 4. Path Verification
if [ ! -d "$SRC_PROFILE" ]; then
    echo "Error: Source profile not found at $SRC_PROFILE"
    exit 1
fi

# 5. Copy Profile
mkdir -p "$FF_DIR"
echo "Copying profile to $FF_DIR..."
cp -r "$SRC_PROFILE" "$FF_DIR/"
chown -R "$REAL_USER":"$REAL_USER" "$FF_DIR/$PROFILE_NAME"

# 6. Update profiles.ini
INI_FILE="$FF_DIR/profiles.ini"

if [ -f "$INI_FILE" ]; then
    echo "Updating $INI_FILE..."
    # 1. Wipe Dedicated Profile [Install] blocks
    sed -i '/^\[Install/,/^$/d' "$INI_FILE"
    # 2. Remove all existing Default flags
    sed -i '/Default=1/d' "$INI_FILE"
    sed -i '/^Default=/d' "$INI_FILE"
    
    # 3. Add or Set this profile as Default
    if ! grep -q "Path=$PROFILE_NAME" "$INI_FILE"; then
        NEXT_NUM=$(grep -c "\[Profile" "$INI_FILE")
        echo -e "\n[Profile$NEXT_NUM]\nName=$PROFILE_NAME\nIsRelative=1\nPath=$PROFILE_NAME\nDefault=1" >> "$INI_FILE"
    else
        sed -i "/Path=$PROFILE_NAME/a Default=1" "$INI_FILE"
    fi
else
    # Create new if missing
    cat <<EOF > "$INI_FILE"
[General]
StartWithLastProfile=1

[Profile0]
Name=default
IsRelative=1
Path=$PROFILE_NAME
Default=1
EOF
fi

# 7. Final Clean
rm -f "$FF_DIR/installs.ini"
chown "$REAL_USER":"$REAL_USER" "$INI_FILE"

echo "Done! Profile $PROFILE_NAME set for $REAL_USER."