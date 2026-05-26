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
    # celý výstup ping-u
    RAW=$(ping -c 1 "$TARGET")

    # zapíš celý ping do logu
    echo "$(date +"[%Y-%m-%d %H:%M:%S]") $RAW" >> "$LOGFILE"

    # extrahuj iba riadok s odpoveďou
    LINE=$(echo "$RAW" | grep "bytes from")

    if [ -n "$LINE" ]; then
        echo "$LINE"   # vypíš na obrazovku

        # extrahuj čas
        TIME=$(echo "$LINE" | grep -o "time=[0-9.]*" | cut -d= -f2)
        TIME_INT=${TIME%.*}

        [ -n "$TIME_INT" ] && stats_add "$TIME_INT"
    else
        echo "timeout"
    fi
done
