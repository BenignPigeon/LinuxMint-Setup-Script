#!/usr/bin/env bash
clear
set -e

echo "============================================="
echo "   Installing RenderCV on Linux Mint...      "
echo "============================================="

# 1. Update system package lists, ignoring errors from broken third-party repos
echo "--> Updating package repositories..."
sudo apt-get update --ignore-missing 2>&1 | grep -v "^E:" || true

# 2. Install pipx and prerequisites
echo "--> Installing pipx and python3 prerequisites..."
sudo apt-get install -y pipx python3-pip python3-setuptools python3-venv

# 3. Ensure pipx is added to PATH
echo "--> Configuring PATH for pipx..."
pipx ensurepath

# Apply PATH changes to the current script session
export PATH="$HOME/.local/bin:$PATH"

# 4. Install RenderCV with full features
echo "--> Installing RenderCV..."
pipx install "rendercv[full]" --force

# 5. Verify the installation
echo "--> Verifying installation..."
if command -v rendercv &> /dev/null; then
    echo "✅ RenderCV successfully installed!"
    rendercv --version
else
    echo "❌ 'rendercv' command not found. Trying direct path..."
    if "$HOME/.local/bin/rendercv" --version &> /dev/null; then
        echo "✅ Found at ~/.local/bin/rendercv — PATH just needs reloading."
    else
        echo "❌ Installation failed."
        exit 1
    fi
fi

# 6. Add to ~/.bashrc permanently if not already there
echo "--> Ensuring ~/.local/bin is permanently in PATH..."
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo "   Added to ~/.bashrc"
else
    echo "   Already in ~/.bashrc"
fi

# Also add to ~/.profile for login shells
if ! grep -q '.local/bin' ~/.profile 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
fi

# 7. Setup a quick-start testing environment
echo "--> Creating a test RenderCV project in ~/RenderCV_Test..."
mkdir -p ~/RenderCV_Test
cd ~/RenderCV_Test
"$HOME/.local/bin/rendercv" new "John_Doe"

echo "--> Rendering test PDF..."
"$HOME/.local/bin/rendercv" render ~/RenderCV_Test/John_Doe_CV.yaml

echo "============================================="
echo "🎉 Setup complete!"
echo "Your test CV: ~/RenderCV_Test/rendercv_output/John_Doe_CV.pdf"
echo ""
echo "👉 Run this now to use rendercv immediately:"
echo "   source ~/.bashrc"
echo "============================================="
clear