#!/bin/bash

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
