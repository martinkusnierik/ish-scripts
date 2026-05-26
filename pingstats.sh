#!/bin/sh

. ./shared_stats.sh

CONFIG_FILE="./ping.conf"
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"
: "${TARGET:=sme.sk}"

LOGFILE="pinglog_$(date +"%Y-%m-%d_%H-%M-%S").txt"

finish() {
    echo ""
    stats_print | tee -a "$LOGFILE"
    exit 0
}

trap finish INT

echo "Timestamped ping to $TARGET"
echo "Logging to $LOGFILE"
echo "Press CTRL+C to stop"
echo ""

while true; do
    LINE=$(ping -c 1 "$TARGET")

    # vypíš ping na obrazovku
    echo "$LINE"

    # zapíš ping do logu s timestampom
    echo "$(date +"[%Y-%m-%d %H:%M:%S]") $LINE" >> "$LOGFILE"

    # extrahuj čas
    TIME=$(echo "$LINE" | grep -o "time=[0-9.]*" | cut -d= -f2)
    TIME_INT=${TIME%.*}

    # pridaj do štatistík
    [ -n "$TIME_INT" ] && stats_add "$TIME_INT"
done
