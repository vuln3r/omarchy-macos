# lyx-theme

Omarchy-artiges Setup für macOS. Getestet auf MacBook Pro 16" M1 Max, macOS 27.0.

| Baustein | Rolle | Config |
|---|---|---|
| [AeroSpace](https://nikitabobko.github.io/AeroSpace/) | Tiling-WM | `aerospace.toml` → `~/.aerospace.toml` |
| [SketchyBar](https://felixkratz.github.io/SketchyBar/) | Statusleiste | `sketchybar/` → `~/.config/sketchybar` |
| [JankyBorders](https://github.com/FelixKratz/JankyBorders) | Fensterrahmen | `bordersrc` → `~/.config/borders/bordersrc` |
| [Ghostty](https://ghostty.org) | Terminal | `ghostty/config` → `~/.config/ghostty/config` |
| [Starship](https://starship.rs) | Prompt | `starship.toml` → `~/.config/starship.toml` |

Farbschema durchgehend **Osaka Jade** (aus [Omarchy](https://omarchy.org), Quelle:
`basecamp/omarchy` → `themes/osaka-jade/colors.toml`), Schrift **JetBrainsMono Nerd Font**.
Alle Configs liegen hier und sind nach `~` verlinkt — Bearbeiten hier wirkt sofort.

---

## Tastenkürzel

`alt` ist die **⌥ Option**-Taste. AeroSpace greift diese Kombinationen systemweit ab,
sie erreichen die darunterliegende App also nicht mehr.

### Fenster & Fokus

| Kürzel | Wirkung |
|---|---|
| `alt` + `H` `J` `K` `L` | Fokus nach links / unten / oben / rechts |
| `alt` + `←` `↓` `↑` `→` | dasselbe mit Pfeiltasten |
| `alt` `shift` + `H` `J` `K` `L` | Fenster verschieben |
| `alt` `shift` + `←` `↓` `↑` `→` | dasselbe mit Pfeiltasten |
| `alt` + `-` | Fenster verkleinern |
| `alt` + `=` | Fenster vergrößern |
| `alt` + `F` | Vollbild an/aus |
| `alt` `shift` + `Q` | Fenster schließen |

### Layout

| Kürzel | Wirkung |
|---|---|
| `alt` + `/` | Kacheln horizontal ↔ vertikal |
| `alt` + `,` | Akkordeon horizontal ↔ vertikal |
| `alt` `shift` + `Leertaste` | schwebend ↔ gekachelt |

### Workspaces

| Kürzel | Wirkung |
|---|---|
| `alt` + `1`…`9` | Workspace wechseln |
| `alt` `shift` + `1`…`9` | Fenster auf Workspace schieben |
| `alt` + `Tab` | zurück zum vorigen Workspace |
| `alt` `shift` + `Tab` | Workspace auf nächsten Monitor schieben |
| `alt` `ctrl` + `←` `→` | Monitor wechseln |
| Klick auf Zahl in der Leiste | Workspace wechseln |

### Programme

| Kürzel | Wirkung |
|---|---|
| `alt` + `Enter` | Ghostty öffnen |
| `alt` + `B` | Google Chrome öffnen |

### Service-Modus — `alt` `shift` + `;`

| Taste | Wirkung |
|---|---|
| `Esc` | Config neu laden, zurück |
| `R` | Layout-Baum zurücksetzen |
| `F` | schwebend ↔ gekachelt |
| `Backspace` | alle Fenster außer dem aktuellen schließen |
| `alt` `shift` + `H` `J` `K` `L` | Fenster zusammenfassen (join) |

### Resize-Modus — `alt` + `R`

| Taste | Wirkung |
|---|---|
| `H` / `L` | schmaler / breiter |
| `K` / `J` | niedriger / höher |
| `B` | Größen ausgleichen |
| `Esc` oder `Enter` | zurück |

### Tastatur

| Taste | Wirkung |
|---|---|
| `Feststelltaste` | **Escape** (via `hidutil`, überlebt Neustart per LaunchAgent) |

---

## Das musst du noch selbst machen

Fünf Dinge lassen sich nicht skripten. Stand geprüft am 28.08.2026 auf diesem Mac —
was schon passt, steht unten unter „erledigt".

### 1. Menüleiste automatisch ausblenden — **von install.sh gesetzt, wirkt nach Neuanmeldung**

`install.sh` setzt `defaults write NSGlobalDomain _HIHideMenuBar -bool true`.
Der WindowServer liest das erst beim Anmelden, also einmal ab- und anmelden.
Wer nicht warten will, klickt es an derselben Stelle von Hand — das wirkt sofort:

> Systemeinstellungen → Kontrollzentrum → Menüleiste automatisch ein-/ausblenden → **Immer**

Sonst liegen Apples Menüleiste und SketchyBar übereinander. Am 16"-Display mit
Notch wird das sonst besonders unschön.

### 2. Bewegung reduzieren — **offen, optional**

> Systemeinstellungen → Bedienungshilfen → Anzeige → **Bewegung reduzieren**

Nimmt die Überblend-Animation beim Workspace-Wechsel raus. Ohne das wirkt das
Tiling träge. Reine Geschmackssache.

### 3. Ghostty als Standardterminal — **offen, optional**

Ghostty einmal öffnen → Ghostty → Einstellungen → als Standard setzen.

### 4. Raycast als Launcher — **offen**

Raycast ist das macOS-Gegenstück zu Omarchys Launcher. Der Hotkey gehört Raycast
selbst, AeroSpace kann ihn nicht setzen:

> Raycast → Settings → General → Raycast Hotkey → **⌥ Leertaste**

`⌥ Leertaste` statt `⌘ Leertaste` liegt näher an Omarchys `Super`+`Space` und
lässt Spotlight in Ruhe. Farblich passend wird Raycast über
[themes.ray.so](https://themes.ray.so) — Palette steht unten unter „Farben".

### 5. Beim ersten Start auf einem anderen Mac: Bedienungshilfen

> Systemeinstellungen → Datenschutz & Sicherheit → Bedienungshilfen → **AeroSpace**

Ohne diese Freigabe kann AeroSpace keine Fenster bewegen.

### Erledigt — nichts zu tun

- **Bedienungshilfen für AeroSpace**: bereits erteilt, verifiziert (22 Fenster sichtbar).
- **Spaces automatisch umsortieren**: bereits aus (`mru-spaces = 0`). Muss aus bleiben,
  sonst nummeriert macOS die Spaces unter AeroSpace um.
- **Feststelltaste in den Systemeinstellungen**: kein Override gesetzt, kollidiert also
  nicht mit `hidutil`. Falls du dort später etwas einstellst, gewinnt die
  Systemeinstellung und die Escape-Belegung ist weg.

---

## Monitore

`aerospace.toml`, Abschnitt `[workspace-to-monitor-force-assignment]`.
Die Liste je Workspace ist eine Prioritätenliste — der erste Treffer gewinnt,
`main` trifft immer und ist der Sicherheitsanker.

| Situation | Was passiert |
|---|---|
| **Wien**, BenQ RD320U | 1–6 auf dem BenQ. Bei geschlossenem Deckel rutschen 7–9 über `main` ebenfalls dorthin. |
| **Bihac**, Odyssey G9 | greift über `.*Odyssey.*` bzw. `.*Samsung.*`, sonst über `main`. |
| **Unterwegs**, nur intern | alles auf `main` = internes Display. |

Bestätigt ist nur der BenQ (`aerospace list-monitors` → `1 | BenQ RD320U`).

**In Bihac einmal prüfen:**

```sh
aerospace list-monitors
```

Steht dort weder `Odyssey` noch `Samsung` im Namen, den echten Namen in
`aerospace.toml` bei den Workspaces 1–6 ergänzen. Auch ohne das funktioniert
alles — dann greift eben `main`, und du hast nur keine feste Aufteilung.

Der 32:9 bekommt durch `default-root-container-orientation = 'auto'` automatisch
horizontales Splitting, da ist nichts weiter zu tun.

---

## Bedienen

```sh
aerospace reload-config              # Config neu laden (auch alt+shift+; dann Esc)
brew services restart sketchybar     # Leiste neu starten
brew services restart borders        # Rahmen neu starten
```

`auto-reload-config = true` ist gesetzt: Änderungen an `aerospace.toml` greifen
beim Speichern von selbst.

## Deinstallieren

```sh
cd ~/lyx-theme
./uninstall.sh              # Configs, LaunchAgent, Tastenbelegung zurück
./uninstall.sh --packages   # zusätzlich die Homebrew-Pakete entfernen
```

Dreht alles zurück: Symlinks weg, gesicherte Originale aus `.backup/` zurück,
LaunchAgent entladen und gelöscht, `hidutil` auf Werkszustand, Starship-Block
aus der `.zshrc` (Sicherungskopie als `.zshrc.lyx-bak`). Die Homebrew-Pakete
bleiben stehen, außer du gibst `--packages` an. `jq` wird nie entfernt.

Kein SIP-Eingriff, keine Kernel-Extension, kein `sudo` — weder bei der
Installation noch beim Entfernen.

---

## Farben — Osaka Jade

Aus `basecamp/omarchy`, `themes/osaka-jade/colors.toml`. Wer das Theme woanders
nachbauen will (Raycast, VS Code, …), nimmt diese Werte:

| Rolle | Hex |
|---|---|
| Hintergrund | `#111c18` |
| Hintergrund dunkler | `#0c1512` |
| Hintergrund heller | `#23372b` |
| Vordergrund | `#c1c497` |
| Akzent (Jade) | `#509475` |
| Auswahl | `#32473b` |
| gedämpft | `#53685b` |
| Rot | `#ff5345` |
| Grün | `#549e6a` |
| Gelb | `#e5c736` |
| Cyan | `#2dd5b7` |
| Magenta | `#d2689c` |
| Orange | `#a2734b` |

Zentral gepflegt in `sketchybar/colors.sh` — SketchyBar und die Plugins lesen
beide von dort, sonst driften Leiste und Workspace-Hervorhebung auseinander.
