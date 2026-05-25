#!/bin/bash

# 1. Ensure the script is running on Linux Mint / Ubuntu / Debian
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" != "linuxmint" && "$ID" != "ubuntu" && "$ID" != "debian" && "$ID_LIKE" != *"ubuntu"* ]]; then
        echo "Error: This script is tailored for Linux Mint/Ubuntu systems."
        exit 1
    fi
else
    echo "Error: Cannot determine OS distribution."
    exit 1
fi

# 2. Check for xinput (required to identify hardware details cleanly)
if ! command -v xinput &> /dev/null; then
    echo "xinput not found. Installing it now..."
    sudo apt update && sudo apt install -y xinput
fi

# 3. Detect Touchpad Name
TOUCHPAD_NAME=$(xinput list --name-only | grep -iE 'touchpad|synaptics|elan|pixa' | head -n 1)

if [ -z "$TOUCHPAD_NAME" ]; then
    echo "Error: Could not automatically detect your touchpad name."
    exit 1
fi

echo "Found Touchpad: $TOUCHPAD_NAME"

# 4. Generate native X11 libinput configuration override
# This applies a scrolling structural transformation matrix directly to the hardware.
X11_CONF_DIR="/etc/X11/xorg.conf.d"
X11_CONF_FILE="$X11_CONF_DIR/99-touchpad-scroll-speed.conf"

echo "Writing native X11 driver configuration override..."
sudo mkdir -p "$X11_CONF_DIR"

# Using 'ScrollPixelDistance' at X11 initialization level to step down tracking velocity
sudo tee "$X11_CONF_FILE" > /dev/null << EOF
Section "InputClass"
        Identifier "Touchpad Scroll Speed Adjustment"
        MatchDevicePath "/dev/input/event*"
        MatchProduct "$TOUCHPAD_NAME"
        Driver "libinput"
        Option "ScrollPixelDistance" "40"
EndSection
EOF

echo "=========================================================="
echo " Configuration complete!"
echo " Applied system rule to: $X11_CONF_FILE"
echo " Please REBOOT your laptop to reload the X11 input engine."
echo "=========================================================="