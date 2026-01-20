# 1. Identify the actual human user and their ID
REAL_USER=$SUDO_USER
USER_ID=$(id -u "$REAL_USER")

echo "🛠 Applying UI preferences for $REAL_USER (UID: $USER_ID)..."

# 2. Run the block with the required DBUS variable
sudo -u "$REAL_USER" \
  DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
  bash <<EOF
    # File manager: show hidden files
    gsettings set org.nemo.preferences show-hidden-files true

    # Desktop: show home and bin icons
    gsettings set org.nemo.desktop home-icon-visible true
    gsettings set org.nemo.desktop trash-icon-visible true

    # Set Notepad to light theme
    gsettings set org.x.editor.preferences.editor scheme 'kate'

    # Start Albert
    # nohup albert >/dev/null 2>&1 &

    # Make Albert run at startup
    # mkdir -p ~/.config/autostart && printf "[Desktop Entry]\nType=Application\nName=Albert\nExec=albert\nX-GNOME-Autostart-enabled=true\n" > ~/.config/autostart/albert.desktop
EOF

echo "✅ All UI settings applied."