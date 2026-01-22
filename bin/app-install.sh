# 1. Check if jq is installed, install if not
if ! command -v jq &> /dev/null; then
    echo "jq not found, installing..."
    sudo apt update && sudo apt install -y jq
    echo "✅ jq installed successfully!"
else
    echo "ℹ️ jq is already installed. Skipping installation."
fi


# 2. Install Albert
if ! command -v albert &> /dev/null; then
    echo "Albert not found, installing..."
    REPO_URL="https://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_24.04"

    curl -fsSL "${REPO_URL}/Release.key" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/albert.gpg > /dev/null
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/albert.gpg] ${REPO_URL}/ /" | sudo tee /etc/apt/sources.list.d/albert.list > /dev/null

    sudo apt update
    sudo apt install -y albert

    mkdir -p ~/.config/autostart
    cp /usr/share/applications/albert.desktop ~/.config/autostart/
    
    echo "✅ Albert installed successfully!"
else
    echo "ℹ️ Albert is already installed. Skipping installation."
fi

# -------------------------------------------------------------------------
# Alter pinned apps

sudo bash ./bin/pin-app.sh libreoffice-writer.desktop

# sudo bash ./bin/pin-app.sh -r firefox.desktop

# Reload Cinnamon panel for that user
sudo -u "$SUDO_USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $SUDO_USER)/bus" cinnamon-dbus-command RestartCinnamon 1

echo "-----------------------------------------------"
echo "✅ SUCCESS: All apps installed successfully!"
echo "-----------------------------------------------"