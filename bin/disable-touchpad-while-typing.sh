#!/bin/bash

# ---------------------------------------------------------
# Script: fix_touchpad_typing.sh
# Purpose: Enable "syndaemon" for reliable touchpad disabling
# ---------------------------------------------------------

set -e

# 1. Check for Root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root: sudo $0"
    exit 1
fi

REAL_USER=$(logname)
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

echo "📦 Installing Synaptics input driver..."
apt-get update -qq
apt-get install -y xserver-xorg-input-synaptics

# 2. Create X11 Configuration Override
echo "📂 Configuring X11 synaptics override..."
mkdir -p /etc/X11/xorg.conf.d
cp -v /usr/share/X11/xorg.conf.d/70-synaptics.conf /etc/X11/xorg.conf.d/70-synaptics.conf

# 3. Create the Startup Application entry
# This creates a .desktop file in the user's autostart folder
echo "🚀 Creating Startup Application for $REAL_USER..."
AUTOSTART_DIR="$USER_HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

cat <<EOF > "$AUTOSTART_DIR/syndaemon.desktop"
[Desktop Entry]
Type=Application
Exec=syndaemon -i 1.0 -K -R -t
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=10
Name[en_US]=Syndaemon
Name=Syndaemon
Comment[en_US]=Disable touchpad while typing (1s delay, tapping/scrolling only)
Comment=Disable touchpad while typing (1s delay, tapping/scrolling only)
EOF

# Ensure the user owns the new autostart file
chown "$REAL_USER":"$REAL_USER" "$AUTOSTART_DIR/syndaemon.desktop"

echo "------------------------------------------------"
echo "✅ Touchpad fix applied successfully!"
echo "🛠️  NOTE: Remember to manually turn OFF 'Disable touchpad while typing'"
echo "    in Menu -> Mouse and Touchpad settings to avoid conflicts."
echo "🔄 Please REBOOT or Log Out to activate the changes."
echo "------------------------------------------------"