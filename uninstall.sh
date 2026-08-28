#!/usr/bin/env bash
# lyx-theme — Deinstallation
# Dreht alles zurueck, was install.sh angefasst hat.
#
#   ./uninstall.sh              Configs, LaunchAgent, Tastenbelegung zurueck
#   ./uninstall.sh --packages   zusaetzlich die Homebrew-Pakete entfernen
#
# Kein sudo noetig. Die Pakete bleiben standardmaessig stehen — die zu
# loeschen ist die einzige Aktion hier, die weh tun kann, also nur auf Ansage.

set -euo pipefail

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$THEME_DIR/.backup"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
AGENT_LABEL="at.sadu.lyx.capslock-escape"
AGENT_PLIST="$LAUNCH_AGENTS/$AGENT_LABEL.plist"
ZSHRC="$HOME/.zshrc"
MARK_BEGIN="# >>> lyx-theme >>>"
MARK_END="# <<< lyx-theme <<<"

REMOVE_PACKAGES=0
[ "${1:-}" = "--packages" ] && REMOVE_PACKAGES=1

info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m ok\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*"; }

# --- Dienste stoppen --------------------------------------------------------
info "Dienste stoppen"
brew services stop sketchybar >/dev/null 2>&1 && ok "sketchybar gestoppt" || warn "sketchybar lief nicht"
brew services stop borders    >/dev/null 2>&1 && ok "borders gestoppt"    || warn "borders lief nicht"
pkill -x borders 2>/dev/null || true
pkill -x sketchybar 2>/dev/null || true

if pgrep -xq AeroSpace; then
    osascript -e 'quit app "AeroSpace"' 2>/dev/null || pkill -x AeroSpace || true
    ok "AeroSpace beendet"
fi

# --- LaunchAgent + Tastenbelegung ------------------------------------------
info "Feststelltaste zuruecksetzen"
launchctl bootout "gui/$UID/$AGENT_LABEL" 2>/dev/null && ok "LaunchAgent entladen" || warn "LaunchAgent war nicht geladen"
[ -f "$AGENT_PLIST" ] && rm -f "$AGENT_PLIST" && ok "plist geloescht"
# Leere UserKeyMapping = Werkszustand, wirkt sofort.
hidutil property --set '{"UserKeyMapping":[]}' >/dev/null && ok "Tastenbelegung zurueckgesetzt"

# --- macOS-Menueleiste zurueck ----------------------------------------------
info "macOS-Menueleiste wieder einblenden"
defaults delete NSGlobalDomain _HIHideMenuBar 2>/dev/null && ok "zurueckgesetzt" || warn "war nicht gesetzt"

# --- Symlinks entfernen, Sicherungen zurueckspielen -------------------------
# unlink_one <ziel-absolut>
unlink_one() {
    local dst="$1"
    local bak="$BACKUP_DIR/${dst#$HOME/}"

    if [ -L "$dst" ]; then
        local target; target="$(readlink "$dst")"
        case "$target" in
            "$THEME_DIR"/*)
                rm -f "$dst"
                ok "Link entfernt: ${dst#$HOME/}"
                ;;
            *)
                warn "${dst#$HOME/} zeigt woanders hin ($target) — bleibt unangetastet"
                return
                ;;
        esac
    elif [ -e "$dst" ]; then
        warn "${dst#$HOME/} ist kein lyx-theme-Link — bleibt unangetastet"
        return
    fi

    if [ -e "$bak" ]; then
        mkdir -p "$(dirname "$dst")"
        mv "$bak" "$dst"
        ok "Sicherung zurueckgespielt: ${dst#$HOME/}"
    fi
}

info "Configs entfernen"
unlink_one "$HOME/.aerospace.toml"
unlink_one "$CONFIG_DIR/ghostty/config"
unlink_one "$CONFIG_DIR/sketchybar"
unlink_one "$CONFIG_DIR/borders/bordersrc"
unlink_one "$CONFIG_DIR/starship.toml"

# Leergeraeumte Ordner mitnehmen, aber nur wenn wirklich leer.
for d in "$CONFIG_DIR/ghostty" "$CONFIG_DIR/borders"; do
    [ -d "$d" ] && rmdir "$d" 2>/dev/null && ok "leerer Ordner entfernt: ${d#$HOME/}"
done
[ -d "$BACKUP_DIR" ] && find "$BACKUP_DIR" -type d -empty -delete 2>/dev/null || true

# --- zshrc aufraeumen -------------------------------------------------------
info "zshrc aufraeumen"
if grep -qF "$MARK_BEGIN" "$ZSHRC" 2>/dev/null; then
    cp "$ZSHRC" "$ZSHRC.lyx-bak"
    sed -i '' "/^${MARK_BEGIN}\$/,/^${MARK_END}\$/d" "$ZSHRC"
    # die Leerzeile, die install.sh vor den Block gesetzt hat
    perl -0pi -e 's/\n{3,}\z/\n/' "$ZSHRC"
    ok "Block entfernt (Sicherung: ${ZSHRC#$HOME/}.lyx-bak)"
else
    warn "kein lyx-theme-Block in der zshrc"
fi

# --- Pakete (nur mit --packages) -------------------------------------------
if [ "$REMOVE_PACKAGES" -eq 1 ]; then
    info "Homebrew-Pakete entfernen"
    for c in aerospace ghostty font-jetbrains-mono-nerd-font; do
        brew uninstall --cask "$c" 2>/dev/null && ok "$c" || warn "$c war nicht installiert"
    done
    for f in sketchybar borders starship; do
        brew uninstall --formula "$f" 2>/dev/null && ok "$f" || warn "$f war nicht installiert"
    done
    warn "jq wurde bewusst stehen gelassen — das braucht vermutlich noch was anderes."
else
    info "Homebrew-Pakete bleiben stehen (--packages entfernt sie auch)."
fi

echo
info "Fertig. Neues Terminalfenster oeffnen, damit die zsh ohne Starship startet."
info "Der Ordner $THEME_DIR selbst bleibt liegen — den loeschst du von Hand."
