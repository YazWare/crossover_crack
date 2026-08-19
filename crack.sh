#!/bin/bash

killall CrossOver 2>/dev/null || true

PLIST="$HOME/Library/Preferences/com.codeweavers.CrossOver.plist"
if [ -f "$PLIST" ]; then
    plutil -replace FirstRunDate -string "2099-01-01 00:00:00 +0000" "$PLIST" 2>/dev/null || \
    defaults write com.codeweavers.CrossOver FirstRunDate -string "2099-01-01 00:00:00 +0000"
    echo "✓ patched plist"
fi

BOTTLES_DIR="$HOME/Library/Application Support/CrossOver/Bottles"
if [ -d "$BOTTLES_DIR" ]; then
    for bottle in "$BOTTLES_DIR"/*; do
        REG_FILE="$bottle/system.reg"
        if [ -f "$REG_FILE" ]; then
            sed -i '' '/\[Software\\CodeWeavers\\CrossOver\\cxoffice\]/,/^$/d' "$REG_FILE" 2>/dev/null || \
            sed -i '/\[Software\\CodeWeavers\\CrossOver\\cxoffice\]/,/^$/d' "$REG_FILE" 2>/dev/null
            echo "✓ cleaned registry for $(basename "$bottle")"
        fi
    done
fi

find "$HOME/Library/Application Support/CrossOver" -name ".update-timestamp" -delete 2>/dev/null
find "$HOME/Library/Application Support/CrossOver" -name ".trial-*" -delete 2>/dev/null
echo "✓ removed timestamp files"

echo "done ✅ enjoy your free crossover"

