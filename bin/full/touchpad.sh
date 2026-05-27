#!/usr/bin/env bash

# ==============================================================================
# Script Name:  setup_touchpad_v2.sh
# Description:  Intelligently configures Linux Mint touchpad to mimic Windows 
#               (Right-click corners, 3-finger middle click, and 3-finger swipes).
# ==============================================================================

# Ensure the script is run with sudo privileges for installations
if [ "$EUID" -ne 0 ]; then
  echo "[-] Error: Please run this script with sudo or as root."
  echo "    Example: sudo ./setup_touchpad_v2.sh"
  exit 1
fi

# Get the actual user logged into the X session
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo "~$REAL_USER")

echo "[+] Starting Advanced Touchpad Configuration for user: $REAL_USER"
echo "------------------------------------------------------------------"

# ------------------------------------------------------------------------------
# 1. FIX RIGHT-CLICK & MIDDLE-CLICK (Cinnamon Native Settings)
# ------------------------------------------------------------------------------
echo "[*] Configuring Right-Click behavior (Touchpad Corners)..."

# Set right-click to physical corners (Windows style) instead of multi-finger
sudo -u "$REAL_USER" gsettings set org.cinnamon.desktop.peripherals.touchpad click-method 'areas'
sudo -u "$REAL_USER" gsettings set org.cinnamon.desktop.peripherals.touchpad tap-to-click true

# Linux Mint handles 3-finger tap natively as middle-click if configured.
# Let's force xinput/gsettings to recognize 3-finger tap mapping if available.
echo "[*] Enabling 3-finger tap to emulate Middle-Click..."
sudo -u "$REAL_USER" gsettings set org.cinnamon.desktop.peripherals.touchpad tap-three-finger-click 2 2>/dev/null || true

# ------------------------------------------------------------------------------
# 2. INSTALL TOUCHEGG (GESTURE DAEMON)
# ------------------------------------------------------------------------------
echo "[*] Syncing gesture engine tools..."

if ! command -v touchegg &> /dev/null; then
    echo "[*] Installing Touchegg daemon..."
    apt-get update -y && apt-get install touchegg -y
    systemctl enable touchegg
    systemctl start touchegg
else
    echo "[~] Touchegg daemon is already installed."
fi

# ------------------------------------------------------------------------------
# 3. WRITE WINDOWS-EXACT GESTURE CONFIGURATION FILE
# ------------------------------------------------------------------------------
echo "[*] Writing Windows-exact 3-finger configuration..."

CONFIG_DIR="$USER_HOME/.config/touchegg"
CONFIG_FILE="$CONFIG_DIR/touchegg.conf"

if [ ! -d "$CONFIG_DIR" ]; then
    sudo -u "$REAL_USER" mkdir -p "$CONFIG_DIR"
fi

# Generate the custom XML configuration mapping
# - 3-Finger TAP        -> Mouse Button 2 (Middle Click)
# - 3-Finger SWIPE DOWN -> Super + D (Minimize all / Show Desktop)
# - 3-Finger SWIPE UP   -> Super + W (Workspace overview)
sudo -u "$REAL_USER" tee "$CONFIG_FILE" > /dev/null <<EOF
<touchegg>
  <settings>
    <property name="animation_delay">150</property>
    <property name="action_execute_threshold">20</property>
    <property name="color">auto</property>
    <property name="borderColor">auto</property>
  </settings>
  <application name="All">
    
    <gesture type="TAP" fingers="3">
      <action type="MOUSE_CLICK">
        <button>2</button>
        <on>begin</on>
      </action>
    </gesture>

    <gesture type="SWIPE" fingers="3" direction="DOWN">
      <action type="SEND_KEYS">
        <modifiers>Super</modifiers>
        <keys>d</keys>
        <repeat>false</repeat>
        <on>begin</on>
      </action>
    </gesture>

    <gesture type="SWIPE" fingers="3" direction="UP">
      <action type="SEND_KEYS">
        <modifiers>Super</modifiers>
        <keys>w</keys>
        <repeat>false</repeat>
        <on>begin</on>
      </action>
    </gesture>

  </application>
</touchegg>
EOF

echo "[+] Successfully synchronized custom gesture matrix at $CONFIG_FILE"

# ------------------------------------------------------------------------------
# 4. APPLY CHANGES
# ------------------------------------------------------------------------------
echo "[*] Restarting Touchegg engine to apply new mappings..."
systemctl restart touchegg

echo "------------------------------------------------------------------"
echo "[+] SUCCESS! Your touchpad is now mapped like Windows."
echo "    -> 3-Finger Tap = Middle Click"
echo "    -> 3-Finger Swipe Down = Windows + D (Show Desktop)"
echo "    -> Bottom Right Corner = Right Click"
echo "------------------------------------------------------------------"
echo "[!] IMPORTANT: You must LOG OUT of your Linux Mint session and log back in for changes to take effect."