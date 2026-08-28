#!/usr/bin/env bash
# Laufender Tyme-Timer: Projekt, Aufgabe und bisherige Dauer.
#
# Datenweg ueber die AppleScript-Schnittstelle von Tyme 3:
#   trackedRecordIDs   -> leer heisst, es laeuft nichts
#   GetRecordWithID    -> fuellt lastFetchedTaskRecord
#   properties of ...  -> timeStart/timeEnd/related*ID auf einen Schlag
#
# ponytail: Properties einzeln zu lesen scheitert an Tymes Specifiern
# ("Can't get task id ... of project id ..."), `properties of` funktioniert.
# Genauso GetTaskWithID: liefert einen Specifier, den niemand aufloesen kann —
# deshalb wird der Name ueber projects/tasks/subtasks gesucht. Gezielt, nicht
# als Vollscan: erst das passende Projekt, dann dessen Task, dann dessen
# Subtasks. ~500 ms.
#
# trackedTaskIDs liefert uebrigens die SUBTASK-ID, nicht die des Tasks —
# der Task steckt in relatedTaskID. Angezeigt wird die Subtask (die eigentliche
# Arbeit), der Task ist nur der Rueckfall.

source "$CONFIG_DIR/colors.sh"

# Ohne diesen Check wuerde osascript Tyme bei jedem Bar-Update starten.
if ! pgrep -xq Tyme; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

# Gekuerzt wird im AppleScript: das zaehlt Zeichen, waehrend ${#var} in bash
# je nach Locale ueber Umlaute stolpert — und die kommen in den Tickets vor.
OUT=$(osascript 2>/dev/null <<'AS'
set maxLen to 24
tell application "Tyme"
    set rids to trackedRecordIDs
    if (count of rids) = 0 then return "IDLE"
    GetRecordWithID (item 1 of rids)
    set props to properties of lastFetchedTaskRecord
    set t1 to timeStart of props
    set t2 to timeEnd of props
    set pid to relatedProjectID of props
    set tid to relatedTaskID of props
    set sid to relatedSubTaskID of props
    set secs to ((t2 - t1) as integer)
    set pname to ""
    set nm to ""
    repeat with p in projects
        if (id of p) is pid then
            set pname to name of p
            repeat with t in tasks of p
                if (id of t) is tid then
                    set nm to name of t
                    repeat with sub in subtasks of t
                        if (id of sub) is sid then
                            set nm to name of sub
                            exit repeat
                        end if
                    end repeat
                    exit repeat
                end if
            end repeat
            exit repeat
        end if
    end repeat
    if (count of characters of nm) > maxLen then
        set nm to (text 1 thru (maxLen - 1) of nm) & "…"
    end if
    return pname & "|" & nm & "|" & secs
end tell
AS
)

sketchybar --set "$NAME" drawing=on

if [ -z "$OUT" ] || [ "$OUT" = "IDLE" ]; then
    sketchybar --set "$NAME" icon="" icon.color="$COMMENT" label.drawing=off
    exit 0
fi

PROJECT="${OUT%%|*}"
REST="${OUT#*|}"
TASK="${REST%|*}"
SECS="${REST##*|}"
[ -z "$SECS" ] && exit 0

printf -v ELAPSED '%d:%02d' $((SECS / 3600)) $(((SECS % 3600) / 60))

if [ -n "$TASK" ]; then
    TEXT="${PROJECT}: ${TASK} ${ELAPSED}"
else
    TEXT="${PROJECT} ${ELAPSED}"
fi

sketchybar --set "$NAME" icon="" \
                         icon.color="$ACCENT" \
                         label.drawing=on \
                         label="$TEXT"
