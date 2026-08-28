#!/usr/bin/env bash
# Tyme: running timer, total for today and time left against a daily goal.

# Daily goal in hours. Past it the readout turns green.
GOAL_HOURS=8

# How the data is fetched from the AppleScript interface of Tyme 3:
#   trackedRecordIDs    -> empty means nothing is running right now
#   GetTaskRecordIDs    -> fills fetchedTaskRecordIDs (total for today)
#   GetRecordWithID     -> fills lastFetchedTaskRecord
#   properties of ...   -> timeStart/timeEnd/related*ID in one go
#
# ponytail: three quirks of Tyme's AppleScript, all of which cost time and
# would bite again on the next rewrite:
#   1. Reading properties one by one fails on the specifiers ("Can't get task
#      id ... of project id ..."), `properties of` returns everything at once.
#      GetTaskWithID likewise only hands back a specifier nobody can resolve,
#      so the name is looked up through projects/tasks/subtasks instead.
#   2. trackedRecordIDs / fetchedTaskRecordIDs cannot be iterated directly,
#      they have to be copied into a local variable first.
#   3. trackedTaskIDs returns the SUBTASK id, not the task's. What is shown is
#      the subtask (the actual work), the task is only the fallback.
#
# Fields are separated by ASCII 31, not by "|": task names may contain pipes
# themselves, which would break the parsing below.
#
# Runtime is roughly 550 ms with two records for the day; the daily total costs
# one round trip per record. Raise update_freq if you log many records a day.

source "$CONFIG_DIR/colors.sh"

# Without this check osascript would launch Tyme on every bar update.
if ! pgrep -xq Tyme; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

# Truncation happens in AppleScript: it counts characters, whereas ${#var} in
# bash counts bytes depending on the locale and trips over non-ASCII names.
OUT=$(osascript 2>/dev/null <<'AS'
set maxLen to 24
set sep to (ASCII character 31)
tell application "Tyme"
    set pname to ""
    set nm to ""
    set secs to 0
    set rids to trackedRecordIDs
    if (count of rids) > 0 then
        GetRecordWithID (item 1 of rids)
        set props to properties of lastFetchedTaskRecord
        set secs to (((timeEnd of props) - (timeStart of props)) as integer)
        set pid to relatedProjectID of props
        set tid to relatedTaskID of props
        set sid to relatedSubTaskID of props
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
    end if
    set midnight to (current date)
    set time of midnight to 0
    GetTaskRecordIDs startDate midnight endDate (current date)
    set ids to fetchedTaskRecordIDs
    set total to 0
    repeat with i in ids
        GetRecordWithID (i as text)
        set p2 to properties of lastFetchedTaskRecord
        set total to total + (((timeEnd of p2) - (timeStart of p2)) as integer)
    end repeat
    return pname & sep & nm & sep & secs & sep & total
end tell
AS
)

sketchybar --set "$NAME" drawing=on

if [ -z "$OUT" ]; then
    sketchybar --set "$NAME" icon="" icon.color="$COMMENT" label.drawing=off
    exit 0
fi

IFS=$'\x1f' read -r PROJECT TASK SECS TOTAL <<< "$OUT"
: "${SECS:=0}" "${TOTAL:=0}"

hm() { printf '%d:%02d' $(($1 / 3600)) $((($1 % 3600) / 60)); }

GOAL=$((GOAL_HOURS * 3600))
LEFT=$((GOAL - TOTAL))

if [ "$LEFT" -gt 0 ]; then
    REST="$(hm "$LEFT") left"
    COLOR=$FG
else
    REST="+$(hm $((-LEFT)))"
    COLOR=$GREEN
fi

DAY="$(hm "$TOTAL")/${GOAL_HOURS}h │ $REST"

if [ -n "$PROJECT" ]; then
    sketchybar --set "$NAME" icon="" \
                             icon.color="$ACCENT" \
                             label.drawing=on \
                             label.color="$COLOR" \
                             label="${PROJECT}: ${TASK} $(hm "$SECS") │ $DAY"
else
    sketchybar --set "$NAME" icon="" \
                             icon.color="$COMMENT" \
                             label.drawing=on \
                             label.color="$COLOR" \
                             label="$DAY"
fi
