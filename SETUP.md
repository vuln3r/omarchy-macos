# Manual setup

`install.sh` does everything that can be scripted. What is left is here.
Keybindings and everything else are in [README.md](README.md).

## After the install

### 1. Log out and back in

Two settings are written by `install.sh` but only read at login:

- `_HIHideMenuBar` - hides Apple's menu bar, which would otherwise sit on top
  of SketchyBar. On a display with a notch this looks especially bad.
- `reduceTransparency` - turns off Liquid Glass (macOS 26+), which puts frosted
  glass over the bar and the window borders and washes out the palette.

If you would rather not wait, both switches exist in the UI and take effect
immediately:

> System Settings -> Control Center -> Menu Bar -> Automatically hide
> System Settings -> Accessibility -> Display -> Reduce transparency

### 2. Accessibility for AeroSpace

> System Settings -> Privacy & Security -> Accessibility -> **AeroSpace**

Without this permission AeroSpace cannot move a single window. macOS asks on
first launch.

## Optional

### Reduce motion

> System Settings -> Accessibility -> Display -> **Reduce motion**

Removes the fade animation when switching workspaces. Without it, tiling feels
sluggish. Purely a matter of taste.

### Ghostty as the default terminal

Open Ghostty once -> Ghostty -> Settings -> set as default.

### A launcher

Raycast is the macOS counterpart to Omarchy's launcher. The hotkey belongs to
Raycast itself, AeroSpace cannot set it:

> Raycast -> Settings -> General -> Raycast Hotkey -> **option + space**

`option + space` sits closer to Omarchy's `Super`+`Space` than `command +
space` does, and leaves Spotlight alone. The palette for a matching theme is in
the README.

## Leave this alone

**Do not turn on "Automatically rearrange Spaces"** (System Settings -> Desktop
& Dock). macOS renumbers Spaces underneath AeroSpace when it is on. Check with:

```sh
defaults read com.apple.dock mru-spaces   # must be 0
```

**Do not remap Caps Lock in System Settings.** `install.sh` maps it to Escape
via `hidutil`. If you also set something under Keyboard -> Modifier Keys, the
system setting wins and the Escape mapping is gone.

## Multiple monitors

Workspaces are not pinned to specific monitors out of the box - every workspace
follows whichever monitor has focus. If you want a fixed split, add a section
to `aerospace.toml`. Get your monitor names first:

```sh
aerospace list-monitors
```

Then match on them. The list per workspace is a priority list, first match
wins, and `main` always matches, so it works as the safety net:

```toml
[workspace-to-monitor-force-assignment]
1 = ['.*Studio Display.*', 'main']
2 = ['.*Studio Display.*', 'main']
3 = 'main'
```

With the lid closed, workspaces whose monitor is gone fall through to `main`.
An ultrawide gets horizontal splitting automatically through
`default-root-container-orientation = 'auto'`, so there is nothing else to do.

## Tyme

The time tracking item only does something if [Tyme](https://www.tyme-app.com)
is installed and running; otherwise it hides itself. On the first query macOS
asks whether the terminal or SketchyBar may control Tyme - that prompt has to
be accepted once, or the item stays on the pause icon.
