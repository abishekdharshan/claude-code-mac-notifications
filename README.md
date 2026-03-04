# Claude Code Mac Notifications

Native macOS notifications for [Claude Code](https://claude.ai/claude-code) - get notified when Claude needs your input or finishes a task.

## Install

```bash
git clone https://github.com/abishekdharshan/claude-code-mac-notifications.git
cd claude-code-mac-notifications
./install.sh
```

Then **restart Claude Code**.

## Uninstall

```bash
./uninstall.sh
```

## What You Get

| Notification | When |
|--------------|------|
| ⏳ Input Needed | Claude needs your input (permissions, questions) |
| ✅ Task Complete | Claude finishes responding |

- **Zero dependencies** - uses built-in `osascript`
- **Smart focus detection** - no notifications if your terminal/IDE is focused
- **Cooldown** - 3-second cooldown prevents spam

### Supported Apps

Notifications are skipped when these are focused:

**Terminals:** Terminal, iTerm2, Warp, Alacritty, Kitty, Ghostty, WezTerm, Hyper

**IDEs:** Cursor, VS Code, Windsurf, Zed

## Credits

Inspired by [claude-code-windows-notifications](https://github.com/zebastieneth/claude-code-windows-notifications) by [@zebastieneth](https://github.com/zebastieneth).

## License

MIT
