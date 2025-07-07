#!/usr/bin/env bash
# Make the script exit on any error, and on unset variables
set -euo pipefail

###############################################################################
# install_from_zero_revised.sh
# A more robust, interactive macOS dev-setup script for a fresh start.
#
# Key Improvements:
#   • Added a critical check to ensure Homebrew is in the PATH before continuing.
#   • Refined output messages for better clarity.
#   • Ensured all installations use the latest Homebrew formulas.
#
# Installs:
#   • Xcode Command-Line Tools
#   • Homebrew (with Apple Silicon & Intel support)
#   • Core CLIs: Python 3.12, Node 20 (via nvm), Git, common Unix tools
#   • Terminal Upgrades: Nerd Font (MesloLGS NF) & Starship prompt
#   • GUI Apps: Visual Studio Code, Docker, Rectangle, Raycast, Insomnia, Maccy
###############################################################################

# --- Helper Functions ---
confirm() {
  # $1 = prompt message
  while true; do
    read -rp "$1 [Y/n] " yn
    case "${yn,,}" in
      y|"") return 0;;
      n)    return 1;;
    esac
  done
}

info() {
  # Standardized info message format
  printf "\n👉  %s\n\n" "$1"
}

success() {
  # Standardized success message format
  printf "✅  %s\n" "$1"
}

# --- 1. Xcode Command-Line Tools ---
if confirm "Install Xcode Command-Line Tools?"; then
  info "Checking for Xcode Command-Line Tools..."
  # Check if they are already installed to avoid the pop-up
  if ! xcode-select -p &>/dev/null; then
    info "Starting installation... Please click 'Install' in the system dialog."
    xcode-select --install
    
    info "Waiting for installation to complete..."
    until xcode-select -p &>/dev/null; do
      sleep 5
    done
  fi
  success "Xcode Command-Line Tools are installed."
fi

---

# --- 2. Homebrew ---
if ! command -v brew &>/dev/null; then
  if confirm "Install Homebrew?"; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configure shell for Homebrew based on architecture
    if [[ "$(uname -m)" == "arm64" ]]; then # Apple Silicon
      BREW_PREFIX="/opt/homebrew"
    else # Intel
      BREW_PREFIX="/usr/local"
    fi
    
    info "Adding Homebrew to your shell profile..."
    # Add the shellenv command to .zprofile if it's not already there
    grep -qxF "eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\"" ~/.zprofile \
      || printf "\neval \"\$(${BREW_PREFIX}/bin/brew shellenv)\"\n" >> ~/.zprofile
    
    # Add Homebrew to the current shell session
    eval "$(${BREW_PREFIX}/bin/brew shellenv)"
  fi
fi

# --- CRITICAL CHECK: Verify Homebrew is ready ---
if ! command -v brew &>/dev/null; then
  info "❌ Homebrew is not available in your PATH. Please restart your terminal and run the script again."
  exit 1
else
  success "Homebrew is installed and in your PATH."
fi

---

# --- 3. Core Packages & Runtimes ---
info "Updating Homebrew and all formulas. This might take a few minutes..."
brew update

# 3a. Python 3.12
if confirm "Install Python 3.12?"; then
  brew install python@3.12
  # `brew link` is often not needed, as Homebrew adds a symlink to python3
  success "Python installed. Version: $(python3 --version)"
fi

# 3b. nvm & Node.js 20
if confirm "Install nvm & Node.js 20?"; then
  brew install nvm
  mkdir -p ~/.nvm
  {
    echo '' # Add a newline for separation
    echo 'export NVM_DIR="$HOME/.nvm"'
    echo '[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"'
  } >> ~/.zprofile
  
  # Source the just-added lines to use nvm in this session
  export NVM_DIR="$HOME/.nvm"
  source "$(brew --prefix nvm)/nvm.sh"
  
  nvm install 20
  nvm alias default 20
  success "Node.js installed. Version: $(node -v) | npm version: $(npm -v)"
fi

# 3c. Git
if confirm "Install latest Git from Homebrew?"; then
  brew install git
  success "Git installed. Version: $(git --version)"
fi

# 3d. Unix Utilities
if confirm "Install handy Unix tools (htop, tree, jq, wget)?"; then
  brew install htop tree jq wget
  success "Unix utilities installed."
fi

---

# --- 4. Terminal Enhancements ---
# 4a. Nerd Font (for icons and symbols)
if confirm "Install MesloLGS Nerd Font?"; then
  brew tap homebrew/cask-fonts
  brew install --cask font-meslo-lg-nerd-font
  info "ACTION REQUIRED: Set your terminal's font to 'MesloLGS NF' in its preferences."
fi

# 4b. Starship Prompt
if confirm "Install Starship prompt?"; then
  brew install starship
  grep -qxF 'eval "$(starship init zsh)"' ~/.zshrc \
    || echo 'eval "$(starship init zsh)"' >> ~/.zshrc
  info "Starship installed. It will be active the next time you open a terminal."
fi

---

# --- 5. GUI Applications ---
info "Now installing selected GUI applications..."

# 5a. Visual Studio Code
if confirm "Install Visual Studio Code?"; then
  brew install --cask visual-studio-code
  success "VS Code installed."
  info "Checking for 'code' command. It should be available automatically."
fi

# 5b. Docker Desktop
if confirm "Install Docker Desktop?"; then
  brew install --cask docker
  info "Docker Desktop installed. Launch it from Applications to complete the setup."
fi

# 5c. Other Developer Apps
if confirm "Install Rectangle, Raycast, Insomnia, and Maccy?"; then
  brew install --cask rectangle raycast insomnia maccy
  info "Productivity apps installed. Launch them from Applications to configure."
fi

---

# --- 6. Final System Check ---
if confirm "Run 'brew doctor' to check for any remaining issues?"; then
  brew doctor
fi

info "🎉 Setup complete! 🚀"
info "Please restart your terminal (or run 'exec zsh') to ensure all changes are applied."

exit 0
