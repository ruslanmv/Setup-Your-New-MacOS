#!/bin/bash

# --- Stop Docker Desktop ---
echo "Quitting Docker Desktop application..."
# Check if Docker is running and attempt to quit gracefully first.
if pgrep -x "Docker" > /dev/null; then
    # Use AppleScript for a graceful quit.
    osascript -e 'quit app "Docker"'
    # Wait a few seconds to allow for a clean shutdown.
    sleep 5
fi

# As a fallback, forcefully kill any remaining Docker processes.
pkill -f Docker
pkill -f "Docker Desktop"


# --- User Confirmation ---
# This is a critical step to prevent accidental data loss.
echo
echo "⚠️  WARNING: This script will permanently uninstall Docker Desktop and delete ALL associated data,"
echo "including containers, images, volumes, and configurations."
echo
read -p "Are you absolutely sure you want to continue? (y/n) " -n 1 -r
echo # Move to a new line for better formatting.
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 1
fi


# --- Uninstall Application via Homebrew ---
echo
echo "Uninstalling Docker Desktop application via Homebrew..."
# Check if 'docker' is listed as an installed cask before trying to uninstall.
if brew list --cask | grep -q "docker"; then
    brew uninstall --cask docker
else
    echo "Docker Desktop does not appear to be installed via Homebrew. Attempting manual removal."
fi

# Manually remove the application bundle as a fallback.
if [ -d "/Applications/Docker.app" ]; then
    echo "Removing Docker application from the /Applications folder..."
    rm -rf "/Applications/Docker.app"
fi


# --- Clean Up All Residual Docker Data ---
echo
echo "Removing all Docker data and configuration files..."

# An array of common paths where Docker stores its data.
paths_to_remove=(
    "$HOME/Library/Application Support/Docker Desktop"
    "$HOME/Library/Caches/com.docker.docker"
    "$HOME/Library/Preferences/com.docker.docker.plist"
    "$HOME/Library/Group Containers/group.com.docker"
    "$HOME/Library/Logs/Docker Desktop"
    "$HOME/Library/Saved Application State/com.docker.docker.savedState"
    "$HOME/.docker"
)

# Loop through the array and remove each file/directory if it exists.
for path in "${paths_to_remove[@]}"; do
    if [ -e "$path" ]; then
        echo "Deleting: $path"
        rm -rf "$path"
    else
        echo "Skipping (not found): $path"
    fi
done


# --- Remove CLI Tool Symlinks ---
# Homebrew usually handles this, but this ensures they are gone.
echo
echo "Cleaning up Docker CLI symlinks..."
cli_tools=(
    "/usr/local/bin/docker"
    "/usr/local/bin/docker-compose"
    "/usr/local/bin/docker-credential-desktop"
    "/usr/local/bin/docker-credential-ecr-login"
    "/usr/local/bin/docker-credential-osxkeychain"
    "/usr/local/bin/hub-tool"
    "/usr/local/bin/docker-machine"
)

for tool in "${cli_tools[@]}"; do
    if [ -L "$tool" ]; then # Check if it's a symbolic link.
        echo "Deleting symlink: $tool"
        rm -f "$tool"
    fi
done

echo
echo "✅ Docker Desktop has been successfully uninstalled."