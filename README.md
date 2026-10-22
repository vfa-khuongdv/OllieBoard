# OllieBoard

Anime desktop pets for macOS. The characters wander around your Desktop, sleep, play with each other, and kick and tidy your real Desktop icons. Every AI coding agent session you have running (Claude Code, Codex, Gemini…) also gets its own mascot that tells you when the agent is done or needs your approval.

The app lives in the menu bar (🐾) only; it has no Dock icon.

## Features

- **8 characters:** Anya Forger (Spy x Family), Nezuko Kamado (Kimetsu no Yaiba), Frieren (Sousou no Frieren), Hitori Gotoh (Bocchi the Rock!) and Rem (Re:Zero), plus chibi caricatures of Donald Trump, Vladimir Putin and Xi Jinping. Each has its own personality and two special moves.
- **Desktop interaction:** characters kick icons across the screen, or line them up in a neat grid in the top-right corner of the main screen.
- **Play room:** a room drawn on the Desktop, underneath your app windows. Characters placed in it stay on its floor and only play with each other.
- **AI agent mascots:** running sessions of Claude Code, Codex, Gemini CLI, OpenCode, Cursor Agent and Aider are detected automatically.
- **3 dialogue languages:** Vietnamese, English and Japanese.

## Install

1. Download `OllieBoard-<version>.dmg` from [Releases](https://github.com/vfa-khuongdv/OllieBoard/releases/latest), open it and drag **OllieBoard** into **Applications**.
2. The app is only ad-hoc signed (not notarized), so on first launch right-click it → **Open** → **Open**.
   If macOS says the app is damaged:
   ```sh
   xattr -dr com.apple.quarantine /Applications/OllieBoard.app
   ```
3. Allow OllieBoard to control **Finder** when asked. This is what lets the characters move your Desktop icons.

Requirements: macOS 13 or later, Apple Silicon (releases are currently built for arm64 only).

## Usage

Everything is in the 🐾 menu in the menu bar. The menu labels are in Vietnamese (only the characters' dialogue is localized), so the English meaning is given below.

| Menu item | What it does |
| --- | --- |
| Nhân vật (Characters) | Turn each character on or off. Only Nezuko is on by default. |
| Phòng chơi (Play room) | Show the room, choose who is inside it, and move or resize it. |
| Ngôn ngữ / Language / 言語 | Change the dialogue language. |
| Nhân vật cho AI agent (Characters for AI agents) | Turn agent mascots on or off, pick which agents, install the Claude Code hook. |
| Đá một icon ngay (Kick an icon now) | Make a character kick an icon right away. |
| Dọn dẹp Desktop (Tidy up Desktop) | Make a character arrange the icons. |

Interacting with a character directly:

- **Click:** the character is happy. Clicking repeatedly (4 times within 3 seconds) annoys it, except Bocchi, who melts. Clicking a sleeping character wakes it up.
- **Drag and drop:** pick a character up and put it somewhere else.
- **Right-click:** opens the menu of that character's special moves.

Bocchi is shy and runs away from the mouse cursor.

### When icons don't move

- The menu shows **⚠️ Chưa điều khiển được Finder** (can't control Finder): choose **Mở cài đặt quyền Automation…** (open Automation settings) and enable Finder access for OllieBoard.
- The menu shows **⚠️ Desktop đang bật Sort By — icon bị khoá** (Sort By is on, icons are locked): choose **Tắt Sort By trên Desktop** (turn off Sort By), or turn it off yourself in Finder (View → Sort By → None).

## AI agent mascots

OllieBoard scans the process list every 2 seconds for `claude`, `codex`, `gemini`, `opencode`, `cursor-agent` and `aider` sessions. Each session gets a mascot labeled with the agent and project folder name (for example `Claude · OllieBoard`). A mascot only appears while its agent is working or waiting for you. When the agent finishes or needs approval, the mascot runs to your mouse cursor to tell you. Click it to jump to that session's terminal window.

By default an agent's state is guessed from its CPU usage. For Claude Code you can install hooks to get the exact state: menu → **Nhân vật cho AI agent** → **Cài hook trạng thái cho Claude Code…** (install the status hook for Claude Code). This will:

- create the script `~/Library/Application Support/OllieBoard/claude-hook.sh`;
- add hooks for `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PermissionRequest`, `Notification` and `Stop` to `~/.claude/settings.json`. Your existing hooks are kept, and the previous file is backed up as `settings.json.ollieboard-backup`.

The hooks only take effect for Claude Code sessions started after installing them.

## Build from source

Requirements: macOS 13+ and Xcode 15+ (or a Swift 5.9 toolchain).

```sh
make run
```

| Command | What it does |
| --- | --- |
| `make app` | Regenerate the sprite sheets, build a release binary and wrap it as `build/OllieBoard.app`. |
| `make run` | `make app`, then open the app. |
| `make dmg` | `make app`, then package `build/OllieBoard-<VERSION>.dmg` (default `VERSION=1.0`). |
| `make sprites` | Regenerate the sprite sheets only. |
| `make clean` | Remove build output. |

`make` calls `scripts/build-app.sh`, which you can also run directly.

The app is ad-hoc signed by default, so macOS asks for Finder access again after every rebuild. To keep the permission between builds, sign with a fixed certificate:

```sh
security find-identity -v -p codesigning   # list available certificates
SIGN_IDENTITY="Apple Development: ..." make app
```

## Project layout

```
Sources/
  OllieBoard/            The app
    AppDelegate.swift    Menu bar menu
    World.swift          Owns the characters, the animation clock and icon assignment
    Pet.swift            Behavior and special moves of one character
    PetWindow.swift      Transparent window that draws a character and handles the mouse
    Room.swift           The play room
    DesktopIcons.swift   Reads and moves Desktop icons through AppleScript (Finder)
    AgentMonitor.swift   Detects running AI agent sessions
    ClaudeHooks.swift    Installs the status hooks for Claude Code
    Characters.swift     Character list and personalities
    Dialogue*.swift      Dialogue per language
    Resources/Sprites/   Sprite sheets generated by SpriteGen
  SpriteGen/             Draws the characters with Core Graphics and writes the sprite sheets
scripts/build-app.sh     Builds and packages OllieBoard.app
Makefile                 Shortcuts for building, running and packaging
```
