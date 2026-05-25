#!/bin/bash

# --- 1. Disable Airplane Mode Key (Framework Hardware Rule) ---
UDEV_FILE="/etc/udev/hwdb.d/99-no-airplane-mode.hwdb"
echo "Creating hwdb rule for Framework Airplane Mode key..."
sudo tee "$UDEV_FILE" > /dev/null <<'EOF'
evdev:input:b0018v32ACp0006*
 KEYBOARD_KEY_100c6=reserved
EOF
sudo systemd-hwdb update
echo "Triggering udev..."
sudo udevadm trigger
sleep 1.5

# --- 2. Write the xmodmap ---
XMODMAP_FILE="$HOME/.Xmodmap"
cat > "$XMODMAP_FILE" <<'EOF'
keycode 107 = Home
keycode 234 = End
EOF
echo "✓ Written ~/.Xmodmap"

# --- 3. Fix the xkb symbols file ---
sudo tee /usr/share/X11/xkb/symbols/framework_keys > /dev/null <<'EOF'
partial alphanumeric_keys
xkb_symbols "framework" {
    key <PRSC> { [ Home ] };
    key <I234> { [ End  ] };
};
EOF
echo "✓ Written xkb symbols file"

# --- 4. Write the apply script (xmodmap only, clean and simple) ---
APPLY_SCRIPT="$HOME/.local/bin/apply-framework-keys.sh"
mkdir -p "$HOME/.local/bin"
cat > "$APPLY_SCRIPT" <<'SCRIPT'
#!/bin/bash
xmodmap "$HOME/.Xmodmap"
SCRIPT
chmod +x "$APPLY_SCRIPT"
echo "✓ Written apply script"

# --- 5. Remove old .desktop autostart if present ---
DESKTOP_FILE="$HOME/.config/autostart/framework-keys.desktop"
if [ -f "$DESKTOP_FILE" ]; then
    rm "$DESKTOP_FILE"
    echo "✓ Removed old .desktop autostart"
fi

# --- 6. Install systemd user service ---
mkdir -p "$HOME/.config/systemd/user"
cat > "$HOME/.config/systemd/user/framework-keys.service" <<EOF
[Unit]
Description=Framework Key Remap
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=oneshot
ExecStartPre=/bin/sleep 8
ExecStart=${HOME}/.local/bin/apply-framework-keys.sh
Environment=DISPLAY=:0
RemainAfterExit=yes

[Install]
WantedBy=graphical-session.target
EOF

systemctl --user daemon-reload
systemctl --user enable framework-keys.service
echo "✓ Systemd user service enabled"

# --- 7. Apply right now in the current session ---
xmodmap "$XMODMAP_FILE"
echo "✓ Applied to current session."

echo ""
echo "All done. Reboot to confirm persistence."
echo "After reboot, verify with: systemctl --user status framework-keys.service"