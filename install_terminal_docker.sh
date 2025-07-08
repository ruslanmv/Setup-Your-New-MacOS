#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- 1. Install Homebrew ---
# Check for Homebrew and install if it's missing.
if ! command_exists brew; then
  echo "Homebrew not found. Installing Homebrew... 🍺"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ $? -ne 0 ]; then
    echo "Homebrew installation failed. Please install it manually and re-run this script."
    exit 1
  fi
fi

# --- 2. Install Colima and Docker CLI ---
# Update Homebrew and install the necessary packages.
echo "Updating Homebrew and installing Colima + Docker CLI... 📦"
brew update
brew install colima docker

if [ $? -ne 0 ]; then
  echo "Installation of Colima or Docker failed."
  exit 1
fi

echo "Colima and Docker CLI installed successfully!"

# --- 3. Start the Docker Environment ---
# Start the Colima VM with Docker support.
echo "Starting the Colima virtual machine... 🚀"
echo "This may take a few minutes on the first run as it downloads the necessary components."
colima start

if [ $? -ne 0 ]; then
  echo "Failed to start Colima. Please check for any error messages above."
  exit 1
fi

echo "✅ Docker environment is ready!"
echo "Run 'docker ps' to test the connection."