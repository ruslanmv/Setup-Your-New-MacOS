#!/usr/bin/env bash
set -euo pipefail
###############################################################################
# install_from_zero.sh
# Interactive macOS 14.4 dev-setup script for a fresh start.
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
  printf "\n👉  %s\n\n" "$1"
}

# --- 1. Xcode Command-Line Tools ---
if confirm "Install Xcode Command-Line Tools?"; then
  info "Installing Xcode CLI... Please click 'Install' in the dialog."
  # Trigger install, suppress errors if already installed
  xcode-select --install 2>/dev/null || echo "✓ Already installed or installation is in progress."
  
  info "Waiting for Xcode Tools to be installed..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  info "✓ Xcode CLI is installed at $(xcode-select -p)"
fi

# --- 2. Homebrew ---
if ! command -v brew &>/dev/null; then
  if confirm "Install Homebrew?"; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configure shell for Homebrew
    if [[ "$(uname -m)" == "arm64" ]]; then
      BREW_PREFIX="/opt/homebrew"
    else
      BREW_PREFIX="/usr/local"
    fi
    
    info "Adding Homebrew to your shell profile..."
    grep -qxF "eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\"" ~/.zprofile \
      || printf "\neval \"\$(${BREW_PREFIX}/bin/brew shellenv)\"\n" >> ~/.zprofile
    eval "$(${BREW_PREFIX}/bin/brew shellenv)"
  fi
else
  info "✓ Homebrew already installed: $(brew --version | head -n1)"
fi

# --- 3. Core Packages ---
info "Updating Homebrew and formulae..."
brew update

# 3a. Python 3.12
if confirm "Install Python 3.12?"; then
  brew install python@3.12
  brew link --overwrite --force python@3.12
  info "✓ Python version: $(python3 --version)"
fi

# 3b. nvm & Node 20
if confirm "Install nvm & Node 20?"; then
  brew install nvm
  mkdir -p ~/.nvm
  {
    echo '' # Add a newline for separation
    echo 'export NVM_DIR="$HOME/.nvm"'
    echo '[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"'
  } >> ~/.zprofile
  # Source the just-added lines to use nvm in this session
  export NVM_DIR="$HOME/.nvm"
  [ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"
  
  nvm install 20
  nvm alias default 20
  info "✓ Node version: $(node -v) | npm version: $(npm -v)"
fi

# 3c. Git
if confirm "Install latest Git from Homebrew?"; then
  brew install git
  info "✓ Git version: $(git --version)"
fi

# 3d. Unix utilities
if confirm "Install handy Unix tools (dos2unix, wget, htop, tree, jq)?"; then
  brew install dos2unix wget htop tree jq
fi

# --- 4. Terminal Enhancements ---
# 4a. Nerd Font
if confirm "Install MesloLGS Nerd Font?"; then
  brew tap homebrew/cask-fonts
  brew install --cask font-meslo-lg-nerd-font
  info "✓ MesloLGS NF installed. Remember to set your terminal font to 'MesloLGS NF'."
fi

# 4b. Starship Prompt
if confirm "Install Starship prompt?"; then
  brew install starship
  grep -qxF 'eval "$(starship init zsh)"' ~/.zshrc \
    || echo 'eval "$(starship init zsh)"' >> ~/.zshrc
  info "✓ Starship installed. Restart your shell to see the new prompt."
fi

# --- 5. Core GUI Applications ---
# 5a. Visual Studio Code
if confirm "Install Visual Studio Code?"; then
  brew install --cask visual-studio-code
  info "✓ VS Code installed."
  info "Adding 'code' CLI to PATH..."
  # This part is now mostly handled automatically by Homebrew Cask.
  # We will just check and inform the user.
  if ! command -v code &>/dev/null; then
    info "ACTION REQUIRED: Open VS Code, press ⇧⌘P → 'Shell Command: Install code command in PATH'"
  else
    info "✓ 'code' command is available at: $(which code)"
  fi
fi

# --- 6. Essential Developer Apps (GUI) ---
if confirm "Install Docker Desktop?"; then
  brew install --cask docker
  info "✓ Docker Desktop installed."
fi

if confirm "Install Rectangle (window manager)?"; then
  brew install --cask rectangle
  info "✓ Rectangle installed. Launch it from Applications to configure."
fi

if confirm "Install Raycast (Spotlight replacement)?"; then
  brew install --cask raycast
  info "✓ Raycast installed. Launch it to replace Spotlight."
fi

if confirm "Install Insomnia (API client)?"; then
  brew install --cask insomnia
  info "✓ Insomnia installed."
fi

if confirm "Install Maccy (clipboard manager)?"; then
  brew install --cask maccy
  info "✓ Maccy installed. Launch it from Applications."
fi

# --- 7. Final Checks ---
if confirm "Run 'brew doctor' to check for any remaining issues?"; then
  brew doctor
fi

info "🎉 Setup complete! Restart your terminal (or run 'exec zsh') to apply all changes."
info "Enjoy your powerful new macOS dev environment!"
exit 0