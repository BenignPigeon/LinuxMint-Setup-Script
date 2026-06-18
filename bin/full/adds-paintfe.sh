#!/bin/bash

# 1. Create necessary local directories
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/icons
mkdir -p ~/.local/share/applications

echo "🔍 Finding the latest PaintFE AppImage version..."
# Get the latest download URL automatically from GitHub API
LATEST_URL=$(curl -s https://api.github.com/repos/kylejckson/PaintFE/releases/latest | grep "browser_download_url.*AppImage" | head -n 1 | cut -d '"' -f 4)

if [ -z "$LATEST_URL" ]; then
    echo "❌ Error: Could not retrieve the latest download link. Falling back to v1.3.1."
    LATEST_URL="https://github.com/kylejckson/PaintFE/releases/download/v1.3.1/PaintFE-x86_64.AppImage"
fi

echo "📥 Downloading latest AppImage from: $LATEST_URL"
wget -O ~/.local/bin/paintfe.AppImage "$LATEST_URL"

echo "⚙️ Making the AppImage executable..."
chmod +x ~/.local/bin/paintfe.AppImage

echo "🎨 Downloading the official app icon..."
wget -O ~/.local/share/icons/paintfe.png https://raw.githubusercontent.com/kylejckson/PaintFE/main/assets/icons/app_icon.png

echo "🖥️ Creating system menu shortcut with 'Open With' support..."
cat <<EOF > ~/.local/share/applications/paintfe.desktop
[Desktop Entry]
Name=PaintFE
Exec=$HOME/.local/bin/paintfe.AppImage %U
Icon=$HOME/.local/share/icons/paintfe.png
Type=Application
Categories=Graphics;
Terminal=false
MimeType=image/png;image/jpeg;image/bmp;image/webp;image/tiff;
Comment=Paint Functional Edition
EOF

echo "✅ All done! PaintFE is fully configured, icon assigned, and ready in your Application Menu."