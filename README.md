# Claude Code Mac Notifications

Native macOS notifications for [Claude Code](https://claude.ai/claude-code) - get notified when Claude needs your input or finishes a task.

![Task Complete Notification](assets/task-complete.png)
![Input Needed Notification](assets/input-needed.png)

## Features

- **Native macOS notifications** - uses built-in `osascript`, no dependencies
- **Smart focus detection** - skips notifications if your terminal is already focused
- **Cooldown protection** - 3-second cooldown prevents notification spam
- **Custom sounds** - "Ping" for input needed, "Glass" for task complete

### Supported Terminals

Focus detection works with:
- Terminal.app
- iTerm2
- Warp
- Alacritty
- Kitty
- Ghostty

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/claude-code-mac-notifications.git
cd claude-code-mac-notifications
chmod +x install.sh
./install.sh
```

Then restart Claude Code to activate notifications.

## Uninstallation

```bash
./uninstall.sh
```

## How It Works

The installer creates two shell scripts and registers them as Claude Code hooks:

| Hook | Trigger | Notification |
|------|---------|--------------|
| `Notification` | Claude needs input (permissions, questions) | "Input Needed" |
| `Stop` | Claude finishes responding | "Task Complete" |

Scripts are installed to `~/.claude/scripts/` and hooks are added to `~/.claude/settings.local.json`.

## Customization

### Change notification sounds

Edit the scripts in `~/.claude/scripts/` and change the `sound name` parameter. Available sounds:
- Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink

### Adjust cooldown

Change the `3` in the cooldown check to your preferred number of seconds.

### Add more terminals

Add your terminal's app name to the `ACTIVE_APP` check in both scripts.

## Credits

Inspired by [claude-code-windows-notifications](https://github.com/zebastieneth/claude-code-windows-notifications) by [@zebastieneth](https://github.com/zebastieneth).

## License

MIT
