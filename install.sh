#!/usr/bin/env bash
# lyx-theme - installer
# Links the configs into ~/.config, installs missing packages, maps Caps Lock
# to Escape and starts the services.
#
# Everything done here is undone by uninstall.sh.
# No SIP changes, no kernel extensions, no sudo.

set -euo pipefail

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$THEME_DIR/.backup"
MANIFEST="$THEME_DIR/.installed-by-lyx"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
AGENT_LABEL="com.lyx-theme.capslock-escape"
AGENT_PLIST="$LAUNCH_AGENTS/$AGENT_LABEL.plist"
ZSHRC="$HOME/.zshrc"
MARK_BEGIN="# >>> lyx-theme >>>"
MARK_END="# <<< lyx-theme <<<"

info()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m ok\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
die()   { printf '\033[1;31mERROR\033[0m %s\n' "$*" >&2; exit 1; }

# --- Preflight --------------------------------------------------------------
[ "$(uname -s)" = "Darwin" ] || die "This is macOS only."
[ "$EUID" -ne 0 ] || die "Do NOT run this with sudo."

if ! command -v brew >/dev/null 2>&1; then
    for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        [ -x "$p" ] && eval "$($p shellenv)" && break
    done
fi
command -v brew >/dev/null 2>&1 || die "Homebrew not found. https://brew.sh"

# --- Packages ---------------------------------------------------------------
# Names verified 2026-08-28. 'borders' used to be called 'janky-borders', and
# the Nerd Fonts used to live in the now-retired homebrew/cask-fonts tap.
TAPS=(felixkratz/formulae nikitabobko/tap)
# eza, bat, fzf, zoxide and btop are the terminal half of the theme - the
# Omarchy command line, themed in zsh/shell.zsh and btop/.
FORMULAE=(felixkratz/formulae/sketchybar felixkratz/formulae/borders starship fastfetch jq \
          eza bat fzf zoxide btop)
CASKS=(aerospace ghostty font-jetbrains-mono-nerd-font)

info "Checking taps"
for t in "${TAPS[@]}"; do
    if brew tap | grep -qx "$t"; then
        ok "tap $t"
    else
        brew tap "$t" && ok "tap $t added"
    fi
done

info "Checking formulae"
for f in "${FORMULAE[@]}"; do
    short="${f##*/}"
    if brew list --formula "$short" >/dev/null 2>&1; then
        ok "$short"
    else
        info "installing $f"
        brew install "$f" || die "brew install $f failed - renamed? try 'brew search ${short}'"
        echo "formula:$short" >> "$MANIFEST"
    fi
done

info "Checking casks"
for c in "${CASKS[@]}"; do
    if brew list --cask "$c" >/dev/null 2>&1; then
        ok "$c"
    else
        info "installing $c"
        brew install --cask "$c" || die "brew install --cask $c failed - renamed? try 'brew search $c'"
        echo "cask:$c" >> "$MANIFEST"
    fi
done

# --- Link the configs -------------------------------------------------------
# link <source-relative-to-THEME_DIR> <absolute-target>
link() {
    local src="$THEME_DIR/$1" dst="$2"
    [ -e "$src" ] || die "missing source: $src"
    mkdir -p "$(dirname "$dst")"

    # Already pointing at us? Then leave it alone.
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        ok "$dst (already linked)"
        return
    fi

    # A real file or directory is in the way -> back it up once (first wins).
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local bak="$BACKUP_DIR/${dst#$HOME/}"
        if [ -e "$bak" ]; then
            warn "$dst replaced (a backup already exists)"
            rm -rf "$dst"
        else
            mkdir -p "$(dirname "$bak")"
            mv "$dst" "$bak"
            ok "$dst backed up to ${bak#$HOME/}"
        fi
    fi

    ln -s "$src" "$dst"
    ok "$dst -> ${src#$HOME/}"
}

info "Linking configs"
link aerospace.toml            "$HOME/.aerospace.toml"
link ghostty/config            "$CONFIG_DIR/ghostty/config"
link sketchybar                "$CONFIG_DIR/sketchybar"
link bordersrc                 "$CONFIG_DIR/borders/bordersrc"
link starship.toml             "$CONFIG_DIR/starship.toml"
link fastfetch/config.jsonc    "$CONFIG_DIR/fastfetch/config.jsonc"
link zsh/osaka-jade.zsh        "$CONFIG_DIR/zsh/osaka-jade.zsh"
link zsh/shell.zsh             "$CONFIG_DIR/zsh/shell.zsh"
link btop                      "$CONFIG_DIR/btop"
link nvim                      "$CONFIG_DIR/nvim"

chmod +x "$THEME_DIR/sketchybar/sketchybarrc" "$THEME_DIR/sketchybar/plugins/"*.sh "$THEME_DIR/bordersrc"

# --- Hook the shell up ------------------------------------------------------
# The block is rewritten rather than skipped, so re-running this script picks
# up new lines instead of leaving an old block behind.
info "Shell block in $ZSHRC"
if grep -qF "$MARK_BEGIN" "$ZSHRC" 2>/dev/null; then
    sed -i '' "/^${MARK_BEGIN}\$/,/^${MARK_END}\$/d" "$ZSHRC"
    perl -0pi -e 's/\n{3,}\z/\n/' "$ZSHRC"
fi
cat >> "$ZSHRC" <<'ZBLOCK'

# >>> lyx-theme >>>
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"

# eza, bat, fzf and zoxide - the Omarchy command line.
[ -r "$HOME/.config/zsh/shell.zsh" ] && source "$HOME/.config/zsh/shell.zsh"

# Palette for zsh-autosuggestions and zsh-syntax-highlighting. Last in the
# file on purpose - both plugins have to be loaded before this runs.
[ -r "$HOME/.config/zsh/osaka-jade.zsh" ] && source "$HOME/.config/zsh/osaka-jade.zsh"

# A greeting instead of an empty window. Interactive only - scripts and the
# shells editors spawn stay quiet.
[[ -o interactive ]] && command -v fastfetch >/dev/null && fastfetch
# <<< lyx-theme <<<
ZBLOCK
ok "block written"

# --- Quiet login ------------------------------------------------------------
# login(1) prints "Last login:" and "You have mail." above the greeting.
# An empty ~/.hushlogin turns both off; it is a macOS feature, not ours.
if [ -e "$HOME/.hushlogin" ]; then
    ok ".hushlogin already there"
else
    : > "$HOME/.hushlogin"
    ok ".hushlogin created"
fi

# --- Caps Lock -> Escape ----------------------------------------------------
# hidutil ships with macOS, it is not a driver. Takes effect immediately but
# does not survive a reboot, hence the LaunchAgent.
info "Caps Lock to Escape"
HIDUTIL_MAP='{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}'
hidutil property --set "$HIDUTIL_MAP" >/dev/null && ok "active now"

mkdir -p "$LAUNCH_AGENTS"
cat > "$AGENT_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$AGENT_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>$HIDUTIL_MAP</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
PLIST

plutil -lint "$AGENT_PLIST" >/dev/null || die "the LaunchAgent plist is malformed"
launchctl bootout "gui/$UID/$AGENT_LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$UID" "$AGENT_PLIST" && ok "LaunchAgent $AGENT_LABEL loaded"

# --- macOS settings ---------------------------------------------------------
# Otherwise Apple's menu bar sits on top of SketchyBar and both are half visible.
info "Hiding the macOS menu bar"
defaults write NSGlobalDomain _HIHideMenuBar -bool true && ok "_HIHideMenuBar=true (applies after re-login)"

# Liquid Glass (macOS 26+) puts frosted glass over the bar and the window
# borders and washes out Osaka Jade. reduceTransparency turns it off.
info "Turning off Liquid Glass"
defaults write com.apple.universalaccess reduceTransparency -bool true && ok "reduceTransparency=true (applies after re-login)"

# --- Services ---------------------------------------------------------------
info "Starting services"
brew services restart sketchybar >/dev/null && ok "sketchybar"
brew services restart borders    >/dev/null && ok "borders"

if pgrep -xq AeroSpace; then
    aerospace reload-config && ok "AeroSpace reloaded"
else
    open -a AeroSpace && ok "AeroSpace started"
fi

echo
info "Done. What you still have to do yourself is in SETUP.md."
info "AeroSpace needs the Accessibility permission on first launch."
