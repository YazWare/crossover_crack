#!/bin/bash

# Kill CrossOver if running
killall CrossOver 2>/dev/null || true

# 1. Modify the plist (where the trial start date is stored)
PLIST="$HOME/Library/Preferences/com.codeweavers.CrossOver.plist"
if [ -f "$PLIST" ]; then
    # Set FirstRunDate to 99999 days ago (makes it think trial started way in the past)
    # Or better: set it to a future date so trial never expires
    # Using plutil on macOS 10.15+
    plutil -replace FirstRunDate -string "2099-01-01 00:00:00 +0000" "$PLIST" 2>/dev/null || \
    defaults write com.codeweavers.CrossOver FirstRunDate -string "2099-01-01 00:00:00 +0000"
    echo "✓ Patched plist"
fi

# 2. Clean registry entries for all bottles
BOTTLES_DIR="$HOME/Library/Application Support/CrossOver/Bottles"
if [ -d "$BOTTLES_DIR" ]; then
    for bottle in "$BOTTLES_DIR"/*; do
        REG_FILE="$bottle/system.reg"
        if [ -f "$REG_FILE" ]; then
            # Remove the trial tracking entries
            sed -i '' '/\[Software\\CodeWeavers\\CrossOver\\cxoffice\]/,/^$/d' "$REG_FILE" 2>/dev/null || \
            sed -i '/\[Software\\CodeWeavers\\CrossOver\\cxoffice\]/,/^$/d' "$REG_FILE" 2>/dev/null
            echo "✓ Cleaned registry for $(basename "$bottle")"
        fi
    done
fi

# 3. Remove timestamp files
find "$HOME/Library/Application Support/CrossOver" -name ".update-timestamp" -delete 2>/dev/null
find "$HOME/Library/Application Support/CrossOver" -name ".trial-*" -delete 2>/dev/null
echo "✓ Removed timestamp files"

echo "✅ Done! CrossOver trial has been extended."

# Optional: Block phone-home domains (add to /etc/hosts)
if ! grep -q "codeweavers.com" /etc/hosts 2>/dev/null; then
    echo "⚠️  For best results, add these to /etc/hosts:"
    echo "127.0.0.1 codeweavers.com"
    echo "127.0.0.1 www.codeweavers.com"
    echo "127.0.0.1 api.codeweavers.com"
fi
