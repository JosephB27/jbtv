#!/bin/bash
# Package the Roku channel into a .zip for sideloading
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ROKU_DIR="$PROJECT_DIR/roku"
OUTPUT="$SCRIPT_DIR/jbtv.zip"

if [ ! -f "$ROKU_DIR/manifest" ]; then
    echo "ERROR: roku/manifest not found"
    exit 1
fi

# Remove old zip
rm -f "$OUTPUT"

# Create zip with manifest at root level (required by Roku)
cd "$ROKU_DIR"
zip -r "$OUTPUT" . \
    -x "*.DS_Store" \
    -x "__MACOSX/*" \
    -x "*.bak" \
    -x "out/*"

echo "Packaged: $OUTPUT"
echo "Size: $(du -h "$OUTPUT" | cut -f1)"
