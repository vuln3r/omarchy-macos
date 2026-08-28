#!/usr/bin/env bash
# lyx-theme - uninstaller
# Reverts everything install.sh touched.
#
#   ./uninstall.sh              configs, LaunchAgent and key mapping
#   ./uninstall.sh --packages   also remove the Homebrew packages
#
# No sudo required. The packages stay by default - removing them is the only
# action here that can hurt, so it only happens on request.

set -euo pipefail

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$THEME_DIR/.backup"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
AGENT_LABEL="com.lyx-theme.capslock-escape"
AGENT_PLIST="$LAUNCH_AGENTS/$AGENT_LABEL.plist"
ZSHRC="$HOME/.zshrc"
MARK_BEGIN="# >>> lyx-theme >>>"
MARK_END="# <<< lyx-theme <<<"

REMOVE_PACKAGES=0
[ "${1:-}" = "--packages" ] && REMOVE_PACKAGES=1

info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m ok\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*"; }

# --- Stop the services ------------------------------------------------------
info "Stopping services"
brew services stop sketchybar >/dev/null 2>&1 && ok "sketchybar stopped" || warn "sketchybar was not running"
brew services stop borders    >/dev/null 2>&1 && ok "borders stopped"    || warn "borders was not running"
pkill -x borders 2>/dev/null || true
pkill -x sketchybar 2>/dev/null || true

if pgrep -xq AeroSpace; then
    osascript -e 'quit app "AeroSpace"' 2>/dev/null || pkill -x AeroSpace || true
    ok "AeroSpace quit"
fi

# --- LaunchAgent and key mapping --------------------------------------------
info "Restoring Caps Lock"
launchctl bootout "gui/$UID/$AGENT_LABEL" 2>/dev/null && ok "LaunchAgent unloaded" || warn "LaunchAgent was not loaded"
[ -f "$AGENT_PLIST" ] && rm -f "$AGENT_PLIST" && ok "plist removed"
# An empty UserKeyMapping is the factory state and applies immediately.
hidutil property --set '{"UserKeyMapping":[]}' >/dev/null && ok "key mapping reset"

# --- macOS settings ---------------------------------------------------------
# Both keys are deleted rather than set to false, so the system default applies
# again. If you had set either one yourself before lyx-theme, it is gone too.
info "Showing the macOS menu bar again"
defaults delete NSGlobalDomain _HIHideMenuBar 2>/dev/null && ok "reset" || warn "was not set"

info "Turning Liquid Glass back on"
defaults delete com.apple.universalaccess reduceTransparency 2>/dev/null && ok "reset" || warn "was not set"

# --- Remove symlinks, restore backups ---------------------------------------
# unlink_one <absolute-target>
unlink_one() {
    local dst="$1"
    local bak="$BACKUP_DIR/${dst#$HOME/}"

    if [ -L "$dst" ]; then
        local target; target="$(readlink "$dst")"
        case "$target" in
            "$THEME_DIR"/*)
                rm -f "$dst"
                ok "link removed: ${dst#$HOME/}"
                ;;
            *)
                warn "${dst#$HOME/} points elsewhere ($target) - left alone"
                return
                ;;
        esac
    elif [ -e "$dst" ]; then
        warn "${dst#$HOME/} is not a lyx-theme link - left alone"
        return
    fi

    if [ -e "$bak" ]; then
        mkdir -p "$(dirname "$dst")"
        mv "$bak" "$dst"
        ok "backup restored: ${dst#$HOME/}"
    fi
}

info "Removing configs"
unlink_one "$HOME/.aerospace.toml"
unlink_one "$CONFIG_DIR/ghostty/config"
unlink_one "$CONFIG_DIR/sketchybar"
unlink_one "$CONFIG_DIR/borders/bordersrc"
unlink_one "$CONFIG_DIR/starship.toml"

# Take emptied directories with us, but only when they really are empty.
for d in "$CONFIG_DIR/ghostty" "$CONFIG_DIR/borders"; do
    [ -d "$d" ] && rmdir "$d" 2>/dev/null && ok "empty directory removed: ${d#$HOME/}"
done
[ -d "$BACKUP_DIR" ] && find "$BACKUP_DIR" -type d -empty -delete 2>/dev/null || true

# --- Clean up zshrc ---------------------------------------------------------
info "Cleaning up zshrc"
if grep -qF "$MARK_BEGIN" "$ZSHRC" 2>/dev/null; then
    cp "$ZSHRC" "$ZSHRC.lyx-bak"
    sed -i '' "/^${MARK_BEGIN}\$/,/^${MARK_END}\$/d" "$ZSHRC"
    # the blank line install.sh put in front of the block
    perl -0pi -e 's/\n{3,}\z/\n/' "$ZSHRC"
    ok "block removed (backup: ${ZSHRC#$HOME/}.lyx-bak)"
else
    warn "no lyx-theme block in your zshrc"
fi

# --- Packages (only with --packages) ----------------------------------------
if [ "$REMOVE_PACKAGES" -eq 1 ]; then
    info "Removing Homebrew packages"
    for c in aerospace ghostty font-jetbrains-mono-nerd-font; do
        brew uninstall --cask "$c" 2>/dev/null && ok "$c" || warn "$c was not installed"
    done
    for f in sketchybar borders starship; do
        brew uninstall --formula "$f" 2>/dev/null && ok "$f" || warn "$f was not installed"
    done
    warn "jq was deliberately left alone - something else probably needs it."
else
    info "Homebrew packages stay (--packages removes them too)."
fi

echo
info "Done. Open a new terminal window so zsh starts without Starship."
info "The $THEME_DIR directory itself stays - delete it by hand."
