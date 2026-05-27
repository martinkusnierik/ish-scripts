#!/bin/sh

. ./shared_stats.sh

CONFIG_FILE="./ping.conf"
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

: "${TARGET:=sme.sk}"
: "${MTU:=1500}"

PAYLOAD=$((MTU - 28))
[ "$PAYLOAD" -lt 0 ] && PAYLOAD=0

LOGFILE="pingstream_$(date +"%Y-%m-%d_%H-%M-%S").txt"

finish() {
    echo ""
    echo ""
    stats_print | tee -a "$LOGFILE"
    kill $PINGPID 2>/dev/null
    exit 0
}

trap finish INT

echo "Streaming ping to $TARGET (MTU=$MTU, payload=$PAYLOAD)"
echo "Logging to $LOGFILE"
echo "Press CTRL+C to stop"
echo ""

# Spustíme ping ako jeden proces
ping -s "$PAYLOAD" "$TARGET" 2>/dev/null | while read -r LINE; do
    TS=$(date +"[%Y-%m-%d %H:%M:%S]")

    case "$LINE" in
        *"bytes from"*)
            printf "!"

            echo "$TS $LINE" >> "$LOGFILE"

            TIME=$(echo "$LINE" | grep -o "time=[0-9.]*" | cut -d= -f2)
            TIME_INT=${TIME%.*}

            stats_add "$TIME_INT"
            ;;

        *"timeout"*|*"no answer"*|*"unreachable"*)
            printf "."

            echo "$TS timeout" >> "$LOGFILE"
            stats_add "timeout"
            ;;
    esac
done &

PINGPID=$!
wait $PINGPID
