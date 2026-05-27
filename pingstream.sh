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

# Spojíme stdout + stderr
ping -s "$PAYLOAD" "$TARGET" 2>&1 | while read -r LINE; do
    TS=$(date +"[%Y-%m-%d %H:%M:%S]")

    case "$LINE" in
        *"time="*)
            printf "!"
            echo "$TS $LINE" >> "$LOGFILE"

            # extrahuj čas
            TIME=$(echo "$LINE" | sed -n 's/.*time=\([0-9.]*\).*/\1/p')
            TIME_INT=${TIME%.*}

            stats_add "$TIME_INT"
            ;;

        *"bad address"*)
            printf "?"
            echo "$TS bad_address: $LINE" >> "$LOGFILE"
            stats_add "timeout"
            ;;

        *"unknown host"*)
            printf "?"
            echo "$TS unknown_host: $LINE" >> "$LOGFILE"
            stats_add "timeout"
            ;;

        *"Host is unreachable"*)
            printf "U"
            echo "$TS host_unreachable: $LINE" >> "$LOGFILE"
            stats_add "timeout"
            ;;

        *"Network is unreachable"*)
            printf "N"
            echo "$TS network_unreachable: $LINE" >> "$LOGFILE"
            stats_add "timeout"
            ;;

        *"Destination Host Unreachable"*)
            printf "U"
            echo "$TS dest_unreachable: $LINE" >> "$LOGFILE"
            stats_add "timeout"
            ;;

        *"Operation timed out"*)
            printf "."
            echo "$TS timeout" >> "$LOGFILE"
            stats_add "timeout"
            ;;

        *"no answer"*)
            printf "."
            echo "$TS timeout" >> "$LOGFILE"
            stats_add "timeout"
            ;;
    esac
done &

PINGPID=$!
wait $PINGPID
