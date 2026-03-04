#!/bin/bash
# Claude Code Mac Notifications - Uninstaller

set -e

SCRIPTS_DIR="$HOME/.claude/scripts"
SETTINGS_FILE="$HOME/.claude/settings.local.json"

echo "Uninstalling Claude Code Mac Notifications..."
echo ""

# Remove notification scripts
if [[ -f "$SCRIPTS_DIR/notify-input-needed.sh" ]]; then
    rm "$SCRIPTS_DIR/notify-input-needed.sh"
    echo "Removed notify-input-needed.sh"
fi

if [[ -f "$SCRIPTS_DIR/notify-task-complete.sh" ]]; then
    rm "$SCRIPTS_DIR/notify-task-complete.sh"
    echo "Removed notify-task-complete.sh"
fi

# Remove cooldown files
rm -f /tmp/claude-notify-input-cooldown
rm -f /tmp/claude-notify-complete-cooldown

# Remove hooks from settings
if [[ -f "$SETTINGS_FILE" ]]; then
    if grep -q '"hooks"' "$SETTINGS_FILE"; then
        python3 << PYTHON
import json

with open("$SETTINGS_FILE", "r") as f:
    settings = json.load(f)

if "hooks" in settings:
    # Remove Notification and Stop hooks if they contain our scripts
    if "Notification" in settings["hooks"]:
        del settings["hooks"]["Notification"]
    if "Stop" in settings["hooks"]:
        del settings["hooks"]["Stop"]

    # Remove hooks key entirely if empty
    if not settings["hooks"]:
        del settings["hooks"]

with open("$SETTINGS_FILE", "w") as f:
    json.dump(settings, f, indent=2)
PYTHON
        echo "Removed hooks from settings.local.json"
    fi
fi

echo ""
echo "Uninstallation complete!"
echo "Restart Claude Code to apply changes."
