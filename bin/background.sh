#!/bin/bash

# 1. Identify the actual user (the person who ran sudo)
REAL_USER=${SUDO_USER:-$(whoami)}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# 2. Define paths relative to the real user
SAVE_PATH="$USER_HOME/Pictures/milad_fakurian_abstract.jpg"
NEW_WALLPAPER_URL="https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe"

# 3. Get the User ID to access their D-Bus session
USER_ID=$(id -u "$REAL_USER")

# Function to run gsettings as the logged-in user
run_as_user() {
    sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" gsettings "$@"
}

# 4. Check the current wallpaper
CURRENT=$(run_as_user get org.cinnamon.desktop.background picture-uri | sed "s/'//g" | sed "s/file:\/\///g")

echo "Running as: $(whoami) (Targeting user: $REAL_USER)"
echo "Current wallpaper: $CURRENT"

# 5. Logic check
if [[ "$CURRENT" == *"/usr/share/backgrounds/linuxmint/"* ]] || [[ "$CURRENT" == "" ]]; then
    echo "Default wallpaper detected. Updating..."

    # Download image if missing (ensuring the user owns the file)
    if [ ! -f "$SAVE_PATH" ]; then
        wget -q -O "$SAVE_PATH" "$NEW_WALLPAPER_URL"
        chown "$REAL_USER":"$REAL_USER" "$SAVE_PATH"
    fi

    # Set the wallpaper for the actual user
    run_as_user set org.cinnamon.desktop.background picture-uri "file://$SAVE_PATH"
    echo "✅ Wallpaper updated for $REAL_USER."
else
    echo "⚠️ Custom wallpaper already exists. Skipping."
fi

# 6. Change Theme

echo "Applying Mint-Y-Dark-Blue theme elements..."

run_as_user set org.cinnamon.desktop.wm.preferences theme "Mint-Y-Dark-Blue"
run_as_user set org.cinnamon.desktop.interface gtk-theme "Mint-Y-Dark-Blue"
run_as_user set org.cinnamon.desktop.interface icon-theme "Mint-Y-Blue"
run_as_user set org.cinnamon.theme name "Mint-Y-Dark-Blue"