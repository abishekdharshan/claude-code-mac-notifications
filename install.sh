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

# Skip if terminal is already focused
ACTIVE_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
if [[ "$ACTIVE_APP" == "Terminal" ]] || [[ "$ACTIVE_APP" == "iTerm2" ]] || [[ "$ACTIVE_APP" == "Warp" ]] || [[ "$ACTIVE_APP" == "Alacritty" ]] || [[ "$ACTIVE_APP" == "kitty" ]] || [[ "$ACTIVE_APP" == "Ghostty" ]]; then
    exit 0
fi

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

# Send notification
osascript -e 'display notification "Claude needs your input" with title "Input Needed" subtitle "Claude Code" sound name "Ping"'
SCRIPT

# Create notify-task-complete.sh
cat > "$SCRIPTS_DIR/notify-task-complete.sh" << 'SCRIPT'
#!/bin/bash
# Claude Code - Task Complete Notification (macOS)

# Skip if terminal is already focused
ACTIVE_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
if [[ "$ACTIVE_APP" == "Terminal" ]] || [[ "$ACTIVE_APP" == "iTerm2" ]] || [[ "$ACTIVE_APP" == "Warp" ]] || [[ "$ACTIVE_APP" == "Alacritty" ]] || [[ "$ACTIVE_APP" == "kitty" ]] || [[ "$ACTIVE_APP" == "Ghostty" ]]; then
    exit 0
fi

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

# Send notification
osascript -e 'display notification "Claude has finished working" with title "Task Complete" subtitle "Claude Code" sound name "Glass"'
SCRIPT

# Make scripts executable
chmod +x "$SCRIPTS_DIR/notify-input-needed.sh"
chmod +x "$SCRIPTS_DIR/notify-task-complete.sh"

echo "Scripts installed to $SCRIPTS_DIR"

# Update settings.local.json
if [[ -f "$SETTINGS_FILE" ]]; then
    # Check if hooks already exist
    if grep -q '"hooks"' "$SETTINGS_FILE"; then
        echo ""
        echo "WARNING: hooks already exist in $SETTINGS_FILE"
        echo "Please manually add the following hooks configuration:"
        echo ""
        cat << 'HOOKS'
"Notification": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "~/.claude/scripts/notify-input-needed.sh",
        "async": true
      }
    ]
  }
],
"Stop": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "~/.claude/scripts/notify-task-complete.sh",
        "async": true
      }
    ]
  }
]
HOOKS
        echo ""
    else
        # Add hooks to existing settings using Python (available on all Macs)
        python3 << PYTHON
import json

with open("$SETTINGS_FILE", "r") as f:
    settings = json.load(f)

settings["hooks"] = {
    "Notification": [
        {
            "hooks": [
                {
                    "type": "command",
                    "command": "$SCRIPTS_DIR/notify-input-needed.sh",
                    "async": True
                }
            ]
        }
    ],
    "Stop": [
        {
            "hooks": [
                {
                    "type": "command",
                    "command": "$SCRIPTS_DIR/notify-task-complete.sh",
                    "async": True
                }
            ]
        }
    ]
}

with open("$SETTINGS_FILE", "w") as f:
    json.dump(settings, f, indent=2)
PYTHON
        echo "Hooks added to $SETTINGS_FILE"
    fi
else
    # Create new settings file
    cat > "$SETTINGS_FILE" << JSON
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$SCRIPTS_DIR/notify-input-needed.sh",
            "async": true
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$SCRIPTS_DIR/notify-task-complete.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
JSON
    echo "Created $SETTINGS_FILE with hooks"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Restart Claude Code to activate notifications."
echo "You'll get notifications when:"
echo "  - Claude needs your input (permission requests, questions)"
echo "  - Claude finishes a task"
echo ""
echo "To uninstall, run: ./uninstall.sh"
