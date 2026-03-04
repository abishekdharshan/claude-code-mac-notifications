# Claude Code Mac Notifications

Native macOS notifications for [Claude Code](https://claude.ai/claude-code) - get notified when Claude needs your input or finishes a task.

<p align="center">
  <img src="assets/claude-icon.png" alt="Claude Icon" width="80">
</p>

## Features

- **Native macOS notifications** - works out of the box with `osascript`
- **Custom Claude icon** - optional, with `terminal-notifier` (via Homebrew)
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
- WezTerm
- Hyper

## Installation

```bash
git clone https://github.com/abishekdharshan/claude-code-mac-notifications.git
cd claude-code-mac-notifications
./install.sh
```

Then **restart Claude Code** to activate notifications.

### Optional: Custom Claude Icon

For notifications with the Claude icon:

```bash
brew install terminal-notifier
```

Then re-run `./install.sh` or just restart Claude Code (the scripts auto-detect terminal-notifier).

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

Edit the scripts in `~/.claude/scripts/` and change the sound name. Available macOS sounds:
- Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink

### Adjust cooldown

Change the `3` in the cooldown check to your preferred number of seconds.

### Add more terminals

Add your terminal's app name to the `case` statement in both scripts.

### Use a custom icon

Replace `~/.claude/assets/claude-icon.png` with your preferred image.

## Credits

Inspired by [claude-code-windows-notifications](https://github.com/zebastieneth/claude-code-windows-notifications) by [@zebastieneth](https://github.com/zebastieneth).

## License

MIT
