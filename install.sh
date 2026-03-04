#!/bin/bash
# Claude Code Mac Notifications - Installer
# Sends native macOS notifications when Claude Code needs input or finishes a task

set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"
ASSETS_DIR="$CLAUDE_DIR/assets"
SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Claude Code Mac Notifications..."
echo ""

# Create directories
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$ASSETS_DIR"

# Copy icon if available
if [[ -f "$SCRIPT_DIR/assets/claude-icon.png" ]]; then
    cp "$SCRIPT_DIR/assets/claude-icon.png" "$ASSETS_DIR/claude-icon.png"
    echo "Icon installed to $ASSETS_DIR"
fi

# Check for terminal-notifier
HAS_TERMINAL_NOTIFIER=$(which terminal-notifier 2>/dev/null || echo "")

if [[ -n "$HAS_TERMINAL_NOTIFIER" ]]; then
    echo "Found terminal-notifier - notifications will have custom Claude icon"
else
    echo "terminal-notifier not found - using basic notifications"
    echo "For custom icons, run: brew install terminal-notifier"
fi

# Create notify-input-needed.sh
cat > "$SCRIPTS_DIR/notify-input-needed.sh" << 'SCRIPT'
#!/bin/bash
# Claude Code - Input Needed Notification (macOS)

# Skip if terminal is already focused
ACTIVE_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
case "$ACTIVE_APP" in
    Terminal|iTerm2|Warp|Alacritty|kitty|Ghostty|WezTerm|Hyper)
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

# Send notification (prefer terminal-notifier for custom icon)
ICON="$HOME/.claude/assets/claude-icon.png"
if command -v terminal-notifier &>/dev/null && [[ -f "$ICON" ]]; then
    terminal-notifier \
        -title "Input Needed" \
        -subtitle "Claude Code" \
        -message "Claude needs your input" \
        -appIcon "$ICON" \
        -sound "Ping" \
        -ignoreDnD
else
    osascript -e 'display notification "Claude needs your input" with title "Input Needed" subtitle "Claude Code" sound name "Ping"'
fi
SCRIPT

# Create notify-task-complete.sh
cat > "$SCRIPTS_DIR/notify-task-complete.sh" << 'SCRIPT'
#!/bin/bash
# Claude Code - Task Complete Notification (macOS)

# Skip if terminal is already focused
ACTIVE_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
case "$ACTIVE_APP" in
    Terminal|iTerm2|Warp|Alacritty|kitty|Ghostty|WezTerm|Hyper)
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

# Send notification (prefer terminal-notifier for custom icon)
ICON="$HOME/.claude/assets/claude-icon.png"
if command -v terminal-notifier &>/dev/null && [[ -f "$ICON" ]]; then
    terminal-notifier \
        -title "Task Complete" \
        -subtitle "Claude Code" \
        -message "Claude has finished working" \
        -appIcon "$ICON" \
        -sound "Glass" \
        -ignoreDnD
else
    osascript -e 'display notification "Claude has finished working" with title "Task Complete" subtitle "Claude Code" sound name "Glass"'
fi
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
if [[ -z "$HAS_TERMINAL_NOTIFIER" ]]; then
    echo "TIP: For custom Claude icon, run: brew install terminal-notifier"
    echo ""
fi
echo "To uninstall, run: ./uninstall.sh"
