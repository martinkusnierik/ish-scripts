#!/bin/sh

. ./shared_stats.sh   # musí byť prvé!

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

echo "Ping to $TARGET"
echo "Logging to $LOGFILE"
echo "Press CTRL+C to stop"
echo ""

while true; do
    RAW=$(ping -c 1 "$TARGET")

    # extrahuj iba riadok s odpoveďou
    LINE=$(echo "$RAW" | grep "bytes from")

    if [ -n "$LINE" ]; then
        echo "$LINE" | tee -a "$LOGFILE"

        TIME=$(echo "$LINE" | grep -o "time=[0-9.]*" | cut -d= -f2)
        TIME_INT=${TIME%.*}

        stats_add "$TIME_INT"
    else
        echo "timeout" | tee -a "$LOGFILE"
        stats_add "timeout"
    fi
done
