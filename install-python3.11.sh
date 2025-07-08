#!/usr/bin/env bash
set -euo pipefail

# 1. Homebrew
if ! command -v brew &>/dev/null; then
  echo "❌  Homebrew is not installed." >&2; exit 1
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Python 3.11
brew install python@3.11 >/dev/null || brew upgrade python@3.11

# 3. Symlink "python" → python3.11
BREW_BIN="$(brew --prefix)/bin"
ln -sf "$BREW_BIN/python3.11" "$BREW_BIN/python"

# 4. Remove any old alias in ~/.zshrc
ZSHRC="$HOME/.zshrc"
if grep -Fq 'alias python=' "$ZSHRC"; then
  sed -i '' 's/^alias python=.*/# alias python removed—use brew Python/' "$ZSHRC"
  echo "➖  Removed/disabled old python alias in ~/.zshrc"
fi

# 5. Ensure brew’s path export is present (and first)
grep -qxF 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile 2>/dev/null || \
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile

echo "✅  Done.  Open a new terminal **or** run:"
echo "     source ~/.zprofile && hash -r"
echo "   then confirm with:"
echo "     which -a python python3"
echo "     python --version"
