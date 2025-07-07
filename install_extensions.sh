#!/usr/bin/env bash
set -euo pipefail

EXT_FILE="extensions.txt"

# 1. Check that our list of extensions exists
if [[ ! -f "$EXT_FILE" ]]; then
  echo "❌ Error: The file '$EXT_FILE' was not found."
  exit 1
fi

echo "➡️ Normalizing '$EXT_FILE' for macOS..."
# 2. Fix for macOS/BSD sed: use -i '' for in-place editing.
#    This removes the BOM (Byte Order Mark) and Windows-style line endings (CRLF).
sed -i '' '1s/^\xEF\xBB\xBF//' "$EXT_FILE"
sed -i '' 's/\r$//' "$EXT_FILE"

echo "➡️ Starting VS Code extension installation..."
# 3. Loop through the file and install each extension
while IFS= read -r ext || [[ -n "$ext" ]]; do
  # Skip empty lines or lines that start with a '#' (comments)
  if [[ -z "$ext" || "$ext" =~ ^\s*# ]]; then
    continue
  fi

  echo -n "Installing: $ext ... "
  # The '|| true' prevents the script from exiting if a single extension fails.
  # The '--force' flag helps overwrite older versions if they exist.
  if code --install-extension "$ext" --force; then
    echo "✅"
  else
    # The exit code from the 'code' command was non-zero, indicating an error.
    echo "❌ (Failed)"
  fi
  
  # Add a 1-second delay to prevent the VS Code CLI from crashing.
  sleep 1

done < "$EXT_FILE"

echo "🎉 All extensions processed."