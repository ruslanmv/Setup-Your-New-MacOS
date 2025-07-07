#!/usr/bin/env bash
set -euo pipefail

EXT_FILE="extensions.txt"

# 1) check that our list exists
if [[ ! -f "$EXT_FILE" ]]; then
  echo "Error: $EXT_FILE not found!"
  exit 1
fi

# 2) normalize the list: remove BOM and CRLFs in-place
#    (requires GNU sed; this handles both issues)
sed -i '1s/^\xEF\xBB\xBF//' "$EXT_FILE"
sed -i 's/\r$//' "$EXT_FILE"

# 3) loop through, skipping blanks/comments
while IFS= read -r line || [ -n "$line" ]; do
  # trim whitespace
  ext=$(printf '%s' "$line" | xargs)
  # skip empty or comment lines
  [[ -z "$ext" || "${ext:0:1}" == "#" ]] && continue

  echo -n "Installing extension: $ext … "
  if code --install-extension "$ext"; then
    echo "✅"
  else
    echo "❌"
  fi
done < "$EXT_FILE"