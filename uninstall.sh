#!/bin/bash
# Claude Code Mac Notifications - Uninstaller

set -e

echo "Uninstalling Claude Code Mac Notifications..."

rm -f ~/.claude/scripts/notify-input-needed.sh
rm -f ~/.claude/scripts/notify-task-complete.sh
rm -f /tmp/claude-notify-*-cooldown

if [[ -f ~/.claude/settings.local.json ]] && grep -q '"hooks"' ~/.claude/settings.local.json; then
    python3 << 'PYTHON'
import json
with open("$HOME/.claude/settings.local.json".replace("$HOME", __import__("os").environ["HOME"]), "r") as f:
    settings = json.load(f)
if "hooks" in settings:
    settings["hooks"].pop("Notification", None)
    settings["hooks"].pop("Stop", None)
    if not settings["hooks"]:
        del settings["hooks"]
with open("$HOME/.claude/settings.local.json".replace("$HOME", __import__("os").environ["HOME"]), "w") as f:
    json.dump(settings, f, indent=2)
PYTHON
fi

echo "Done! Restart Claude Code."
