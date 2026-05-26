#!/bin/sh

CONFIG_FILE="./ping.conf"
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

: "${TARGET:=sme.sk}"
: "${WINDOW:=50}"
: "${MAX_HEIGHT:=20}"
: "${SCALE:=1}"

LOGFILE="pinglog_$(date +"%Y-%m-%d_%H-%M-%S").txt"

echo "Sliding window ping graph to $TARGET"
echo "Window size: $WINDOW pings"
echo "Logging to: $LOGFILE"
echo "Press CTRL+C to stop"
echo ""

pings=""

draw_graph() {
    clear
    echo "Ping graph (last $WINDOW samples) — target: $TARGET"
    echo ""

    for row in $(seq $MAX_HEIGHT -1 1); do
        line=""
        for val in $pings; do
            [ "$val" -ge "$row" ] && line="${line}#" || line="${line} "
        done
        echo "$line"
    done

    echo "$(printf '%*s' $(echo "$pings" | wc -w) | tr ' ' '-')"
}

while true; do
    LINE=$(ping -c 1 "$TARGET" | grep "time=")

    if [ -z "$LINE" ]; then
        TIME_INT=0
        echo "[timeout]" >> "$LOGFILE"
    else
        TIME=$(echo "$LINE" | awk -F'time=' '{print $2}' | awk '{print $1}')
        TIME_INT=${TIME%.*}
        echo "$(date +"[%Y-%m-%d %H:%M:%S]") $LINE" >> "$LOGFILE"
    fi

    HEIGHT=$((TIME_INT / SCALE))
    [ $HEIGHT -gt $MAX_HEIGHT ] && HEIGHT=$MAX_HEIGHT

    pings="$pings $HEIGHT"
    COUNT=$(echo "$pings" | wc -w)
    [ "$COUNT" -gt "$WINDOW" ] && pings=$(echo "$pings" | cut -d' ' -f2-)

    draw_graph
done
