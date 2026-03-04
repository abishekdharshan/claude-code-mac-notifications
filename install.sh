#!/bin/bash
# Claude Code Mac Notifications - Installer
# Sends native macOS notifications when Claude Code needs input or finishes a task

set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"
SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"

echo "Installing Claude Code Mac Notifications..."
echo ""

# Create scripts directory
mkdir -p "$SCRIPTS_DIR"

# Create notify-input-needed.sh
cat > "$SCRIPTS_DIR/notify-input-needed.sh" << 'SCRIPT'
#!/bin/bash
# Claude Code - Input Needed Notification (macOS)

# Skip if terminal/IDE is already focused
ACTIVE_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
case "$ACTIVE_APP" in
    Terminal|iTerm2|Warp|Alacritty|kitty|Ghostty|WezTerm|Hyper|Cursor|Code|Windsurf|Zed)
        exit 0
        ;;
esac

# 3-second cooldown
COOLDOWN_FILE="/tmp/claude-notify-input-cooldown"
if [[ -f "$COOLDOWN_FILE" ]]; then
    LAST_TIME=$(cat "$COOLDOWN_FILE")
    CURRENT_TIME=$(date +%s)
    if (( CURRENT_TIME - LAST_TIME < 3 )); then
        exit 0
    fi
fi
echo $(date +%s) > "$COOLDOWN_FILE"

osascript -e 'display notification "Claude needs your input" with title "⏳ Input Needed" subtitle "Claude Code" sound name "Ping"'
SCRIPT

# Create notify-task-complete.sh
cat > "$SCRIPTS_DIR/notify-task-complete.sh" << 'SCRIPT'
#!/bin/bash
# Claude Code - Task Complete Notification (macOS)

# Skip if terminal/IDE is already focused
ACTIVE_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
case "$ACTIVE_APP" in
    Terminal|iTerm2|Warp|Alacritty|kitty|Ghostty|WezTerm|Hyper|Cursor|Code|Windsurf|Zed)
        exit 0
        ;;
esac

# 3-second cooldown
COOLDOWN_FILE="/tmp/claude-notify-complete-cooldown"
if [[ -f "$COOLDOWN_FILE" ]]; then
    LAST_TIME=$(cat "$COOLDOWN_FILE")
    CURRENT_TIME=$(date +%s)
    if (( CURRENT_TIME - LAST_TIME < 3 )); then
        exit 0
    fi
fi
echo $(date +%s) > "$COOLDOWN_FILE"

osascript -e 'display notification "Claude has finished working" with title "✅ Task Complete" subtitle "Claude Code" sound name "Glass"'
SCRIPT

# Make scripts executable
chmod +x "$SCRIPTS_DIR/notify-input-needed.sh"
chmod +x "$SCRIPTS_DIR/notify-task-complete.sh"

echo "✓ Scripts installed"

# Update settings.local.json
if [[ -f "$SETTINGS_FILE" ]]; then
    if grep -q '"hooks"' "$SETTINGS_FILE"; then
        echo ""
        echo "⚠ Hooks already exist in settings. Add these manually:"
        echo ""
        echo '"Notification": [{"hooks": [{"type": "command", "command": "~/.claude/scripts/notify-input-needed.sh", "async": true}]}],'
        echo '"Stop": [{"hooks": [{"type": "command", "command": "~/.claude/scripts/notify-task-complete.sh", "async": true}]}]'
        echo ""
    else
        python3 << PYTHON
import json
with open("$SETTINGS_FILE", "r") as f:
    settings = json.load(f)
settings["hooks"] = {
    "Notification": [{"hooks": [{"type": "command", "command": "$SCRIPTS_DIR/notify-input-needed.sh", "async": True}]}],
    "Stop": [{"hooks": [{"type": "command", "command": "$SCRIPTS_DIR/notify-task-complete.sh", "async": True}]}]
}
with open("$SETTINGS_FILE", "w") as f:
    json.dump(settings, f, indent=2)
PYTHON
        echo "✓ Hooks configured"
    fi
else
    cat > "$SETTINGS_FILE" << JSON
{
  "hooks": {
    "Notification": [{"hooks": [{"type": "command", "command": "$SCRIPTS_DIR/notify-input-needed.sh", "async": true}]}],
    "Stop": [{"hooks": [{"type": "command", "command": "$SCRIPTS_DIR/notify-task-complete.sh", "async": true}]}]
  }
}
JSON
    echo "✓ Settings created"
fi

echo ""
echo "Done! Restart Claude Code to activate."
echo ""
echo "You'll get notifications when:"
echo "  ⏳ Claude needs your input"
echo "  ✅ Claude finishes a task"
