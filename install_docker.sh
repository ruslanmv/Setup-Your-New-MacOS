#!/bin/bash

# Script to install and manage a terminal-only Docker environment using Colima

echo "### Script to Install Docker (Terminal-Only) via Colima ###"

# --- 1. Check and Install Homebrew ---
if ! command -v brew &> /dev/null; then
  echo "[*] Homebrew not found. Installing Homebrew... 🍺"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ $? -ne 0 ]; then
    echo "[!] ERROR: Homebrew installation failed. Please install it manually and re-run this script." >&2
    exit 1
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "[*] Homebrew is already installed."
fi

# --- 2. Install Colima, Docker CLI, and Docker Compose ---
echo
echo "[*] Installing/updating Colima, Docker CLI, and Docker Compose... 📦"
# This will install if not present, or update if already installed.
if brew install colima docker docker-compose; then
  echo "[*] Colima, Docker CLI, and Docker Compose are installed."
else
  echo "[!] ERROR: Installation failed." >&2
  exit 1
fi

# --- 3. Start the Docker Environment ---
echo
echo "[*] Checking the Docker environment status..."
# Check if Colima is already running
if colima status &> /dev/null; then
    echo "[*] Docker environment (Colima) is already running."
else
    echo "[*] Starting the Colima virtual machine to enable Docker... 🚀"
    echo "    (This may take a few minutes on the first run.)"
    if ! colima start; then
        echo "[!] ERROR: Failed to start Colima. Please check for any error messages above." >&2
        exit 1
    fi
fi

# --- 4. Final Instructions ---
echo
echo "---"
echo "✅ Docker is ready to use in your terminal!"
echo
echo "## How to Use Your Terminal-Only Docker ##"
echo
echo "IMPORTANT: Unlike Docker Desktop, the Docker engine does not start automatically."
echo
echo "  - To START Docker: Run 'colima start' in your terminal."
echo "  - To STOP Docker:  Run 'colima stop' when you are finished."
echo
echo "After running 'colima start', you can use the 'docker' and 'docker compose' commands."
echo "---"