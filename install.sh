#!/usr/bin/env bash
# lyx-theme — Installation
# Verlinkt die Configs nach ~/.config, installiert fehlende Pakete,
# legt Feststelltaste auf Escape und startet die Dienste.
#
# Alles, was hier passiert, macht uninstall.sh wieder rueckgaengig.
# Kein SIP-Eingriff, keine Kernel-Extensions, kein sudo.

set -euo pipefail

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$THEME_DIR/.backup"
MANIFEST="$THEME_DIR/.installed-by-lyx"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
AGENT_LABEL="at.sadu.lyx.capslock-escape"
AGENT_PLIST="$LAUNCH_AGENTS/$AGENT_LABEL.plist"
ZSHRC="$HOME/.zshrc"
MARK_BEGIN="# >>> lyx-theme >>>"
MARK_END="# <<< lyx-theme <<<"

info()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m ok\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
die()   { printf '\033[1;31mFEHLER\033[0m %s\n' "$*" >&2; exit 1; }

# --- Preflight --------------------------------------------------------------
[ "$(uname -s)" = "Darwin" ] || die "Das hier ist nur fuer macOS."
[ "$EUID" -ne 0 ] || die "Bitte NICHT mit sudo starten."

if ! command -v brew >/dev/null 2>&1; then
    for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        [ -x "$p" ] && eval "$($p shellenv)" && break
    done
fi
command -v brew >/dev/null 2>&1 || die "Homebrew nicht gefunden. https://brew.sh"

# --- Pakete -----------------------------------------------------------------
# Stand geprueft 2026-08-28: das sind die aktuell gueltigen Namen.
# 'borders' hiess frueher 'janky-borders', die Nerd-Fonts lagen frueher
# im inzwischen aufgeloesten Tap homebrew/cask-fonts.
TAPS=(felixkratz/formulae nikitabobko/tap)
FORMULAE=(felixkratz/formulae/sketchybar felixkratz/formulae/borders starship jq)
CASKS=(aerospace ghostty font-jetbrains-mono-nerd-font)

info "Taps pruefen"
for t in "${TAPS[@]}"; do
    if brew tap | grep -qx "$t"; then
        ok "tap $t"
    else
        brew tap "$t" && ok "tap $t ergaenzt"
    fi
done

info "Formeln pruefen"
for f in "${FORMULAE[@]}"; do
    short="${f##*/}"
    if brew list --formula "$short" >/dev/null 2>&1; then
        ok "$short"
    else
        info "installiere $f"
        brew install "$f" || die "brew install $f fehlgeschlagen — Name geaendert? 'brew search ${short}'"
        echo "formula:$short" >> "$MANIFEST"
    fi
done

info "Casks pruefen"
for c in "${CASKS[@]}"; do
    if brew list --cask "$c" >/dev/null 2>&1; then
        ok "$c"
    else
        info "installiere $c"
        brew install --cask "$c" || die "brew install --cask $c fehlgeschlagen — Name geaendert? 'brew search $c'"
        echo "cask:$c" >> "$MANIFEST"
    fi
done

# --- Configs verlinken ------------------------------------------------------
# link <quelle-relativ-zu-THEME_DIR> <ziel-absolut>
link() {
    local src="$THEME_DIR/$1" dst="$2"
    [ -e "$src" ] || die "Quelle fehlt: $src"
    mkdir -p "$(dirname "$dst")"

    # Zeigt der Link schon zu uns? Dann nichts tun.
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        ok "$dst (bereits verlinkt)"
        return
    fi

    # Echte Datei/Ordner vorhanden -> einmalig sichern (erste Sicherung gewinnt).
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local bak="$BACKUP_DIR/${dst#$HOME/}"
        if [ -e "$bak" ]; then
            warn "$dst wird ersetzt (Sicherung existiert bereits)"
            rm -rf "$dst"
        else
            mkdir -p "$(dirname "$bak")"
            mv "$dst" "$bak"
            ok "$dst gesichert nach ${bak#$HOME/}"
        fi
    fi

    ln -s "$src" "$dst"
    ok "$dst -> ${src#$HOME/}"
}

info "Configs verlinken"
link aerospace.toml            "$HOME/.aerospace.toml"
link ghostty/config            "$CONFIG_DIR/ghostty/config"
link sketchybar                "$CONFIG_DIR/sketchybar"
link bordersrc                 "$CONFIG_DIR/borders/bordersrc"
link starship.toml             "$CONFIG_DIR/starship.toml"

chmod +x "$THEME_DIR/sketchybar/sketchybarrc" "$THEME_DIR/sketchybar/plugins/"*.sh "$THEME_DIR/bordersrc"

# --- Starship in die zsh haengen -------------------------------------------
info "Starship in $ZSHRC"
if grep -qF "$MARK_BEGIN" "$ZSHRC" 2>/dev/null; then
    ok "Block schon vorhanden"
else
    cat >> "$ZSHRC" <<'ZBLOCK'

# >>> lyx-theme >>>
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"
# <<< lyx-theme <<<
ZBLOCK
    ok "Block ergaenzt"
fi

# --- Feststelltaste -> Escape ----------------------------------------------
# hidutil ist ein Bordmittel, kein Treiber. Wirkt sofort, ueberlebt aber
# keinen Neustart — deshalb der LaunchAgent.
info "Feststelltaste auf Escape"
HIDUTIL_MAP='{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}'
hidutil property --set "$HIDUTIL_MAP" >/dev/null && ok "sofort aktiv"

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

plutil -lint "$AGENT_PLIST" >/dev/null || die "LaunchAgent-plist ist kaputt"
launchctl bootout "gui/$UID/$AGENT_LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$UID" "$AGENT_PLIST" && ok "LaunchAgent $AGENT_LABEL geladen"

# --- macOS-Einstellungen ----------------------------------------------------
# Sonst liegt die native Leiste ueber der SketchyBar und beide sind halb sichtbar.
info "macOS-Menueleiste ausblenden"
defaults write NSGlobalDomain _HIHideMenuBar -bool true && ok "_HIHideMenuBar=true (wirkt nach Ab-/Anmeldung)"

# Liquid Glass (macOS 26+) legt Milchglas ueber SketchyBar und Fensterraender
# und wischt Osaka Jade weich. Der Schalter dafuer heisst reduceTransparency.
info "Liquid Glass abschalten"
defaults write com.apple.universalaccess reduceTransparency -bool true && ok "reduceTransparency=true (wirkt nach Ab-/Anmeldung)"

# --- Dienste ----------------------------------------------------------------
info "Dienste starten"
brew services restart sketchybar >/dev/null && ok "sketchybar"
brew services restart borders    >/dev/null && ok "borders"

if pgrep -xq AeroSpace; then
    aerospace reload-config && ok "AeroSpace neu geladen"
else
    open -a AeroSpace && ok "AeroSpace gestartet"
fi

echo
info "Fertig. Was du noch selbst machen musst, steht in SETUP.md."
info "AeroSpace braucht beim ersten Start die Bedienungshilfen-Freigabe."
