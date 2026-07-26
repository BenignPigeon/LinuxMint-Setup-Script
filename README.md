# 🌿 Linux Mint Setup Utility

A lightweight, aesthetic Bash pipeline designed to automate the configuration of a fresh Linux Mint installation. It executes a sequence of scripts with real-time visual feedback and safety checks.

### ⚡ Quick Execution (Recommended)
This method uses a lightweight wrapper to fetch the latest release and run it immediately.

```bash
sudo curl -fsSL https://gist.githubusercontent.com/BenignPigeon/c4366353c3c5d47fbe8860de192d2b92/raw/Linux-Mint-Setup-Flags.sh | bash
```

### 🛠️ Manual Alternative
1. Download the source code from the main branch.
2. Unzip the folder
3. Open the terminal and type
```bash
sudo bash /path/to/start.sh
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
