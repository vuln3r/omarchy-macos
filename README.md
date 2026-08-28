# lyx-theme

Ein Tiling-Setup für macOS in **Osaka Jade** — Fenster kacheln sich selbst,
eine eigene Statusleiste ersetzt Apples Menüleiste, und alles trägt dieselbe
Palette. Omarchy-Idee, macOS-Umsetzung.

> Getestet auf MacBook Pro 16" M1 Max, macOS 27.0.

```
   ┌─ SketchyBar ──────────────────────────────────────────────────────┐
   │ 1 2 3 4 5  Ghostty  ▶ APA: Maintenance 2:34   Fri 28.08   68% 80% │
   ├──────────────────────────────┬────────────────────────────────────┤
   │                              │                                    │
   │           Ghostty            │             Chrome                 │
   │                              │                                    │
   └──────────────────────────────┴────────────────────────────────────┘
      JankyBorders zeichnet den Jade-Rahmen ums aktive Fenster
```

Links die Workspaces, die fokussierte App und der laufende Tyme-Timer, mittig
die Uhr, rechts RAM, Lautstärke, Batterie und WLAN.

## Woraus es besteht

| Baustein | Rolle | Config |
|---|---|---|
| [AeroSpace](https://nikitabobko.github.io/AeroSpace/) | Tiling-WM | `aerospace.toml` → `~/.aerospace.toml` |
| [SketchyBar](https://felixkratz.github.io/SketchyBar/) | Statusleiste | `sketchybar/` → `~/.config/sketchybar` |
| [JankyBorders](https://github.com/FelixKratz/JankyBorders) | Fensterrahmen | `bordersrc` → `~/.config/borders/bordersrc` |
| [Ghostty](https://ghostty.org) | Terminal | `ghostty/config` → `~/.config/ghostty/config` |
| [Starship](https://starship.rs) | Prompt | `starship.toml` → `~/.config/starship.toml` |

Alles wird nach `~` **verlinkt**, nicht kopiert — eine Änderung hier wirkt sofort.
`aerospace.toml` lädt sich sogar beim Speichern selbst neu.

## Installieren

```sh
git clone <repo> ~/lyx-theme
cd ~/lyx-theme
./install.sh
```

Braucht [Homebrew](https://brew.sh), sonst nichts. Kein `sudo`, kein SIP-Eingriff,
keine Kernel-Extension. Fehlende Pakete installiert das Skript selbst, vorhandene
Configs wandern vorher nach `.backup/`.

Danach **einmal ab- und anmelden** — zwei macOS-Einstellungen greifen erst dann:
die ausgeblendete Menüleiste und das abgeschaltete Liquid Glass.

Beim ersten Start auf einem neuen Mac fragt AeroSpace nach der
Bedienungshilfen-Freigabe. Ohne die kann es keine Fenster bewegen.

Was sich nicht skripten lässt (Raycast-Hotkey, Ghostty als Standardterminal),
steht in **[SETUP.md](SETUP.md)**.

## Tastenkürzel

`alt` ist die **⌥ Option**-Taste. AeroSpace fängt diese Kombinationen systemweit
ab — sie erreichen die darunterliegende App nicht mehr.

### Fokus & Fenster

| Kürzel | Wirkung |
|---|---|
| `alt` + `H` `J` `K` `G` | Fokus nach links / unten / oben / rechts |
| `alt` `shift` + `H` `J` `K` `G` | Fenster in diese Richtung verschieben |
| `alt` + `-` / `=` | Fenster verkleinern / vergrößern |
| `alt` + `/` | Kacheln horizontal ↔ vertikal |
| `alt` `shift` + `Leertaste` | schwebend ↔ gekachelt |
| `alt` + `F` | Vollbild an/aus |
| `alt` `shift` + `Q` | Fenster schließen |

### Programme

| Kürzel | Wirkung |
|---|---|
| `alt` + `Enter` | neues Ghostty-Fenster |
| `alt` + `B` | Google Chrome |
| `alt` + `S` | Slack |
| `alt` + `C` | Claude |

Die App springt dabei auf ihren Workspace mit (Slack → 4, Claude → 5), weil die
Window-Rules unten sie ohnehin dorthin schicken.

> **Tastenwahl auf österreichischem Layout:** AeroSpace greift die Kombination
> systemweit ab, das Zeichen darunter ist damit weg. `⌥L` ist deshalb bewusst
> *nicht* belegt — das ist das **@**. Aus demselben Grund liegt „Fokus rechts"
> auf `G` statt auf `L`. `⌥S` (‚) und `⌥C` (ç) sind verzichtbar.
> `Y` und `Z` besser meiden: `key-mapping.preset = 'qwerty'` meint die
> *physische* US-Position, und QWERTZ vertauscht genau diese beiden.

### Workspaces

| Kürzel | Wirkung |
|---|---|
| `alt` + `1` … `5` | Workspace wechseln |
| `alt` `shift` + `1` … `5` | Fenster auf Workspace schieben |
| `alt` + `Tab` | zurück zum vorigen Workspace |
| `alt` `shift` + `Tab` | Workspace auf nächsten Monitor schieben |
| Klick auf die Zahl in der Leiste | Workspace wechseln |

### Service-Modus — `alt` `shift` + `;`

| Taste | Wirkung |
|---|---|
| `Esc` | Config neu laden, zurück |
| `R` | Layout-Baum zurücksetzen |
| `F` | schwebend ↔ gekachelt |
| `Backspace` | alle Fenster außer dem aktuellen schließen |
| `alt` `shift` + `H` `J` `K` `L` | Fenster zusammenfassen (join) |

### Tastatur

| Taste | Wirkung |
|---|---|
| `Feststelltaste` | **Escape** — via `hidutil`, überlebt den Neustart per LaunchAgent |

## Fenster sortieren sich selbst

`aerospace.toml` schickt jede App beim Öffnen auf ihren Workspace:

| WS | Inhalt |
|---|---|
| **1** | Cursor, VS Code, Xcode, GitKraken |
| **2** | Ghostty, Warp, iTerm, Terminal |
| **3** | Chrome, Safari |
| **4** | Slack, Mail, Spark, Messages, Calendar |
| **5** | Claude, ChatGPT, Grok, LM Studio |

Utility-Fenster laufen bewusst **floating**: System Settings, Activity Monitor,
Bitwarden, NordVPN, Cisco Secure Client, Finder, Preview, Acrobat. Die lassen
sich nicht schmal genug ziehen und würden das Kacheln sprengen.

Eine App fehlt? Bundle-ID holen und einen Block in `aerospace.toml` ergänzen:

```sh
aerospace list-windows --focused --format '%{app-bundle-id}'
```

```toml
[[on-window-detected]]
if.app-id = 'com.example.app'
run = 'move-node-to-workspace 3'
```

Die Regeln greifen nur bei **neu erkannten** Fenstern. Schon offene Fenster
sortieren sich erst nach einem Neustart von AeroSpace ein.

## Zeiterfassung

Läuft in [Tyme](https://www.tyme-app.com) ein Timer, zeigt die Leiste
`Projekt: Aufgabe h:mm`. Klick öffnet Tyme, ohne Timer bleibt ein gedämpftes
Pause-Symbol, und ist Tyme gar nicht offen, verschwindet das Item.

Angezeigt wird die **Subtask**, nicht der Task: `trackedTaskIDs` liefert die
Subtask-ID, der Task steckt in `relatedTaskID`. Wer seine Tasks „Development"
und „Meetings" nennt und die Arbeit in Subtasks führt, will genau das sehen.
Ab 24 Zeichen wird gekürzt — die Zahl steht als `maxLen` in
`sketchybar/plugins/tyme.sh`.

## Bedienen

```sh
aerospace reload-config              # Config neu laden (oder alt+shift+; dann Esc)
brew services restart sketchybar     # Leiste neu starten
brew services restart borders        # Rahmen neu starten
```

## Anpassen

**Farben** liegen zentral in `sketchybar/colors.sh`. SketchyBar *und* seine
Plugins lesen von dort — Plugins sind eigene Prozesse und sehen die Variablen
aus `sketchybarrc` nicht, deshalb sourct jedes Plugin die Datei selbst.

**Bar-Höhe** hängt an zwei Stellen zusammen: `--bar height` in
`sketchybar/sketchybarrc` und `gaps.outer.top` in `aerospace.toml`. Die Bar ist
`topmost` und reserviert selbst keinen Platz — änderst du die Höhe, muss der
Gap mit, sonst verdeckt sie die oberen Fenster.

**Fensterrahmen** in `bordersrc`: `width` für die Dicke, `active_color` /
`inactive_color` für die Farbe. `style` bleibt sinnvollerweise auf `round` —
macOS rundet Fensterecken seit Big Sur im WindowServer, ein eckiger Rahmen
läuft an der runden Ecke sichtbar daneben.

## Deinstallieren

```sh
./uninstall.sh              # Configs, LaunchAgent, Tastenbelegung zurück
./uninstall.sh --packages   # zusätzlich die Homebrew-Pakete
```

Symlinks weg, Originale aus `.backup/` zurück, LaunchAgent entladen, `hidutil`
auf Werkszustand, Starship-Block aus der `.zshrc` (Kopie als `.zshrc.lyx-bak`).
Die macOS-Einstellungen werden gelöscht, nicht auf `false` gesetzt — hattest du
Menüleiste oder Transparenz schon vorher selbst konfiguriert, ist das danach weg.

## Palette — Osaka Jade

| Rolle | Hex | | Rolle | Hex |
|---|---|---|---|---|
| Hintergrund | `#111c18` | | Rot | `#ff5345` |
| Hintergrund dunkler | `#0c1512` | | Grün | `#549e6a` |
| Hintergrund heller | `#23372b` | | Gelb | `#e5c736` |
| Vordergrund | `#c1c497` | | Cyan | `#2dd5b7` |
| Akzent (Jade) | `#509475` | | Magenta | `#d2689c` |
| Auswahl | `#32473b` | | Orange | `#a2734b` |
| gedämpft | `#53685b` | | | |

Aus [Omarchy](https://omarchy.org), `basecamp/omarchy` →
`themes/osaka-jade/colors.toml`. Schrift durchgehend **JetBrainsMono Nerd Font**.
