#!/bin/bash

# --- 1. Disable Airplane Mode Key FIRST (Framework Hardware Rule) ---
# We do this first because triggering udev resets Cinnamon's keymap.
UDEV_FILE="/etc/udev/hwdb.d/99-no-airplane-mode.hwdb"

echo "Creating hwdb rule for Framework Airplane Mode key..."
sudo tee "$UDEV_FILE" > /dev/null <<'EOF'
evdev:input:b0018v32ACp0006*
 KEYBOARD_KEY_100c6=reserved
EOF

echo "Updating hardware database..."
sudo systemd-hwdb update

echo "Triggering udev system (this causes Mint to reset your keymap)..."
sudo udevadm trigger

# --- 2. Pause Briefly ---
# Give the system and Cinnamon a second to process the hardware trigger
echo "Waiting for background keyboard daemons to settle..."
sleep 1.5

# --- 3. Install xmodmap (Linux Mint / APT) ---
if ! command -v xmodmap &> /dev/null; then
    echo "xmodmap not found. Installing via apt..."
    sudo apt-get update && sudo apt-get install -y x11-xserver-utils
else
    echo "✓ xmodmap is already verified."
fi

# --- 4. Create / Update local .Xmodmap file ---
echo "Configuring F11/F12 rebinds..."
XMODMAP_FILE="$HOME/.Xmodmap"

cat << 'EOF' > "$XMODMAP_FILE"
keycode 107 = Home
keycode 234 = End
EOF

# --- 5. Apply xmodmap NOW (Now that udev is finished) ---
xmodmap "$XMODMAP_FILE"
echo "✓ F11/F12 successfully rebound for this active session."

# --- 6. Make xmodmap load automatically on future boots ---
STARTUP_DIR="$HOME/.config/autostart"
mkdir -p "$STARTUP_DIR"

cat << EOF > "$STARTUP_DIR/xmodmap-remap.desktop"
[Desktop Entry]
Type=Application
Exec=xmodmap $HOME/.Xmodmap
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Custom Key Remap
Comment=Loads custom Home/End binds for F11/F12 on login
EOF

echo "✓ Added xmodmap execution to Linux Mint Startup Applications."
echo "--------------------------------------------------"
