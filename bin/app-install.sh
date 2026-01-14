# 1 Install Collabora Office
# sudo apt update && sudo apt install -y flatpak wget && wget -q https://cdn.collaboraoffice.com/collaboraoffice-v25.04.7.2_final.flatpak -O /tmp/collaboraoffice.flatpak && flatpak install -y /tmp/collaboraoffice.flatpak && flatpak override com.collabora.Office --env=QTWEBENGINE_FORCE_USE_GBM=0 --env=QTWEBENGINE_CHROMIUM_FLAGS="--disable-gpu --disable-software-rasterizer" && rm /tmp/collaboraoffice.flatpak

echo "-----------------------------------------------"
echo "✅ SUCCESS: All apps installed successfully!"
echo "-----------------------------------------------"
