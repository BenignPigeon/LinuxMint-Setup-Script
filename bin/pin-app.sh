#!/bin/bash

# 1. Identify the real user
REAL_USER=$(find /home -maxdepth 1 -not -name 'root' -not -path '/home' -printf '%u\n' | head -n 1)
REAL_HOME="/home/$REAL_USER"
USER_ID=$(id -u "$REAL_USER")
DBUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"

# 2. Config Details
APPLET_ID="grouped-window-list@cinnamon.org"
CONFIG_DIR="$REAL_HOME/.config/cinnamon/spices/$APPLET_ID"

# 3. Parse arguments
UNPIN=false
if [ "$1" = "-r" ]; then
    UNPIN=true
    shift
fi

APP="$1"
[ -z "$APP" ] && exit 1

# 4. Update the JSON file
shopt -s nullglob
CONFIGS=("$CONFIG_DIR"/*.json)

for CONFIG in "${CONFIGS[@]}"; do
    if $UNPIN; then
        echo "Updating config: Unpinning $APP..."
        jq ".\"pinned-apps\".value |= map(select(. != \"$APP\"))" "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
    else
        echo "Updating config: Pinning $APP..."
        jq ".\"pinned-apps\".value += [\"$APP\"] | .\"pinned-apps\".value |= unique" "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
    fi
    chown "$REAL_USER":"$REAL_USER" "$CONFIG"
done

# 5. FORCE UI REFRESH
# We tell Cinnamon to reload the applet. This is the equivalent of 
# right-clicking the panel and hitting 'Reload'.
echo "Refreshing Cinnamon Panel..."
sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDRESS" \
    dbus-send --type=method_call --dest=org.Cinnamon \
    /org/Cinnamon org.Cinnamon.ReloadSpice \
    string:"$APPLET_ID" string:"applet"

echo "Done! $APP should now be visible on the taskbar."