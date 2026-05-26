#!/bin/sh

TARGET="sme.sk"
WINDOW=50
MAX_HEIGHT=20
SCALE=1
LOGFILE="pinglog_$(date +"%Y-%m-%d_%H-%M-%S").txt"

GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
GRAY="\033[90m"
RESET="\033[0m"

echo "Colored sliding window ping graph to $TARGET"
echo "Window size: $WINDOW pings"
echo "Logging to: $LOGFILE"
echo "Press CTRL+C to stop"
echo ""

pings=""
colors=""

draw_graph() {
    clear
    echo "Ping graph (last $WINDOW samples) — target: $TARGET"
    echo ""

    for row in $(seq $MAX_HEIGHT -1 1); do
        line=""
        idx=1
        for val in $pings; do
            color=$(echo "$colors" | cut -d' ' -f$idx)
            if [ "$val" -ge "$row" ]; then
                line="${line}${color}#${RESET}"
            else
                line="${line} "
            fi
            idx=$((idx+1))
        done
        echo "$line"
    done

    echo "$(printf '%*s' $(echo "$pings" | wc -w) | tr ' ' '-')"
}

while true; do
    LINE=$(ping -c 1 "$TARGET" | grep "time=")

    if [ -z "$LINE" ]; then
        TIME_INT=0
        COLOR="$GRAY"
        echo "[timeout]" >> "$LOGFILE"
    else
        TIME=$(echo "$LINE" | awk -F'time=' '{print $2}' | awk '{print $1}')
        TIME_INT=${TIME%.*}
        echo "$(date +"[%Y-%m-%d %H:%M:%S]") $LINE" >> "$LOGFILE"

        if [ "$TIME_INT" -lt 40 ]; then COLOR="$GREEN"
        elif [ "$TIME_INT" -lt 80 ]; then COLOR="$YELLOW"
        else COLOR="$RED"
        fi
    fi

    HEIGHT=$((TIME_INT / SCALE))
    [ $HEIGHT -gt $MAX_HEIGHT ] && HEIGHT=$MAX_HEIGHT

    pings="$pings $HEIGHT"
    colors="$colors $COLOR"

    COUNT=$(echo "$pings" | wc -w)
    [ "$COUNT" -gt "$WINDOW" ] && {
        pings=$(echo "$pings" | cut -d' ' -f2-)
        colors=$(echo "$colors" | cut -d' ' -f2-)
    }

    draw_graph
done
