#!/bin/sh

CONFIG_FILE="./ping.conf"
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

: "${TARGET:=sme.sk}"
: "${MAX_HEIGHT:=20}"
: "${SCALE:=1}"

LOGFILE="pinglog_$(date +"%Y-%m-%d_%H-%M-%S").txt"

echo "Starting ping graph to $TARGET"
echo "Logging to $LOGFILE"
echo "Press CTRL+C to stop"
echo ""

while true; do
    LINE=$(ping -c 1 "$TARGET" | grep "time=")

    if [ -z "$LINE" ]; then
        echo "[timeout]"
        echo "[timeout]" >> "$LOGFILE"
        continue
    fi

    TIME=$(echo "$LINE" | awk -F'time=' '{print $2}' | awk '{print $1}')
    TIME_INT=${TIME%.*}

    echo "$(date +"[%Y-%m-%d %H:%M:%S]") $LINE" >> "$LOGFILE"

    HEIGHT=$((TIME_INT / SCALE))
    [ $HEIGHT -gt $MAX_HEIGHT ] && HEIGHT=$MAX_HEIGHT

    BAR=$(printf "%${HEIGHT}s" | tr ' ' '#')

    printf "%4sms | %s\n" "$TIME" "$BAR"
done
