#!/bin/sh

. ./shared_stats.sh

CONFIG_FILE="./ping.conf"
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

: "${TARGET:=sme.sk}"
: "${MTU:=1500}"

# Prepočet MTU → payload
# MTU = payload + 28 (IP+ICMP header)
PAYLOAD=$((MTU - 28))
[ "$PAYLOAD" -lt 0 ] && PAYLOAD=0

LOGFILE="pingmini_$(date +"%Y-%m-%d_%H-%M-%S").txt"

SEQ=0

finish() {
    echo ""
    echo ""
    stats_print | tee -a "$LOGFILE"
    exit 0
}

trap finish INT

echo "Cisco‑style ping to $TARGET (MTU=$MTU, payload=$PAYLOAD)"
echo "Logging to $LOGFILE"
echo "Press CTRL+C to stop"
echo ""

while true; do
    RAW=$(ping -c 1 -s "$PAYLOAD" "$TARGET")

    LINE=$(echo "$RAW" | grep "bytes from")

    if [ -n "$LINE" ]; then
        # OK reply
        printf "!"
        echo "$LINE" >> "$LOGFILE"

        TIME=$(echo "$LINE" | grep -o "time=[0-9.]*" | cut -d= -f2)
        TIME_INT=${TIME%.*}

        stats_add "$TIME_INT"
    else
        # timeout
        printf "."
        echo "timeout seq=$SEQ mtu=$MTU" >> "$LOGFILE"
        stats_add "timeout"
    fi

    SEQ=$((SEQ + 1))
done
