#!/bin/bash
# Sideload the JBTV channel onto a Roku device
# Usage: ./deploy.sh <ROKU_IP> <DEV_PASSWORD>
set -e

ROKU_IP="$1"
DEV_PASSWORD="$2"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ZIP_FILE="$SCRIPT_DIR/jbtv.zip"

if [ -z "$ROKU_IP" ] || [ -z "$DEV_PASSWORD" ]; then
    echo "Usage: ./deploy.sh <ROKU_IP> <DEV_PASSWORD>"
    echo ""
    echo "Enable Developer Mode on Roku: Home 3x, Up 2x, Right, Left, Right, Left, Right"
    echo "Find Roku IP: Settings > Network > About"
    exit 1
fi

if [ ! -f "$ZIP_FILE" ]; then
    echo "ERROR: $ZIP_FILE not found. Run package.sh first."
    exit 1
fi

echo "Deploying JBTV to Roku at $ROKU_IP..."

# Delete existing channel first
curl --silent --digest --user "rokudev:$DEV_PASSWORD" \
    --form "mysubmit=Delete" \
    --form "archive=" \
    "http://$ROKU_IP/plugin_install" > /dev/null 2>&1 || true

# Install new channel
RESPONSE=$(curl --silent --digest --user "rokudev:$DEV_PASSWORD" \
    --form "mysubmit=Install" \
    --form "archive=@$ZIP_FILE" \
    "http://$ROKU_IP/plugin_install")

if echo "$RESPONSE" | grep -q "Install Success"; then
    echo "SUCCESS: JBTV installed on Roku!"
elif echo "$RESPONSE" | grep -q "Identical"; then
    echo "SUCCESS: JBTV already up to date."
else
    echo "Deploy response:"
    echo "$RESPONSE" | grep -oP 'Roku\.Message = "\K[^"]*' || echo "$RESPONSE"
fi
