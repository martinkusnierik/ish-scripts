#!/bin/sh

TARGET="google.com"
WINDOW=50        # počet posledných pingov v grafe
MAX_HEIGHT=20    # výška grafu
SCALE=1          # 1 ms = 1 jednotka výšky
LOGFILE="pinglog_$(date +"%Y-%m-%d_%H-%M-%S").txt"

# ANSI farby
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
GRAY="\033[90m"
RESET="\033[0m"

echo "Sliding window ping graph with jitter — target: $TARGET"
echo "Window size: $WINDOW pings"
echo "Logging to: $LOGFILE"
echo "Press CTRL+C to stop"
echo ""

pings=""
colors=""
last_ping=""
jitter="0"

draw_graph() {
    clear
    echo "Ping graph (last $WINDOW samples) — target: $TARGET"
    echo "Jitter: ${jitter}ms"
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

        if [ "$TIME_INT" -lt 40 ]; then
            COLOR="$GREEN"
        elif [ "$TIME_INT" -lt 80 ]; then
            COLOR="$YELLOW"
        else
            COLOR="$RED"
        fi
    fi

    # výpočet jitteru (|current - previous|)
    if [ -n "$last_ping" ]; then
        diff=$(( TIME_INT - last_ping ))
        [ $diff -lt 0 ] && diff=$(( -diff ))
        jitter=$diff
    fi
    last_ping=$TIME_INT

    HEIGHT=$((TIME_INT / SCALE))
    [ $HEIGHT -gt $MAX_HEIGHT ] && HEIGHT=$MAX_HEIGHT

    pings="$pings $HEIGHT"
    colors="$colors $COLOR"

    COUNT=$(echo "$pings" | wc -w)
    if [ "$COUNT" -gt "$WINDOW" ]; then
        pings=$(echo "$pings" | cut -d' ' -f2-)
        colors=$(echo "$colors" | cut -d' ' -f2-)
    fi

    draw_graph
done
