# 🌿 Linux Mint Setup Utility

A lightweight, aesthetic Bash pipeline designed to automate the configuration of a fresh Linux Mint installation. It executes a sequence of scripts with real-time visual feedback and safety checks.

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
