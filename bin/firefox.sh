#!/bin/bash

# Source custom Firefox config
SRC="./bin/config/firefox"

# Destination profile folder
DEST="$HOME/.mozilla/firefox/migrated-profile"

# Make sure Firefox is not running
if pgrep -x firefox >/dev/null; then
    echo "Firefox is running. Please close it before running this script."
    exit 1
fi

# Copy the profile safely
echo "Copying Firefox profile from $SRC to $DEST..."
rsync -aP "$SRC/" "$DEST/"

# Inform the user
echo "Profile copied successfully."

# Suggest creating a new profile in Firefox Profile Manager
echo "You can now create a new profile pointing to this folder:"
echo "firefox -P"
echo "Use '$DEST' as the profile folder location."

