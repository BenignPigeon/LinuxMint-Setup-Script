# 1. Install Albert
if ! command -v albert &> /dev/null; then
    echo "Albert not found. Installing for Mint 22 (Noble)..."
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

echo "-----------------------------------------------"
echo "✅ SUCCESS: All apps installed successfully!"
echo "-----------------------------------------------"