# 🌿 Linux Mint Setup Utility

A lightweight, aesthetic Bash pipeline designed to automate the configuration of a fresh Linux Mint installation. It executes a sequence of scripts with real-time visual feedback and safety checks.

### ⚡ Quick Execution (Recommended)
This method uses a lightweight wrapper to fetch the latest release and run it immediately.

```bash
curl -sSL https://gist.githubusercontent.com/BenignPigeon/64cde9ef0cf255a56d0d76c1e0f327b4/raw/linux-mint-setup.sh | bash
```

### 🛠️ Manual Alternative
Use this method if you prefer to download and extract the release files into a temporary directory before running.

```bash
mkdir -p /tmp/mint-setup && \
curl -s https://api.github.com/repos/BenignPigeon/LinuxMint-Setup-Script/releases/latest \
| grep "browser_download_url.*zip" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi - -O /tmp/mint-setup/latest.zip && \
unzip -o /tmp/mint-setup/latest.zip -d /tmp/mint-setup && \
cd /tmp/mint-setup && \
sudo bash start.sh
```

## 🛠 Features
* **Linux Mint Validation:** Prevents accidental execution on unsupported distributions.
* **Sequential Execution:** Runs your setup tasks in a specific, logical order.
* **Live Output Mirroring:** Displays the real-time output of sub-scripts within a structured TUI.
* **Failure Tracking:** Identifies which scripts failed while allowing the rest of the setup to continue.

---

## 📂 Project Structure
```text
linuxsetup/
├── start.sh          # The main manager script
└── bin/              # Directory for setup modules
    ├── 01-update.sh  # Example: System updates
    ├── 02-apps.sh    # Example: Software installation
    └── 03-config.sh  # Example: Desktop environment tweaks
```
