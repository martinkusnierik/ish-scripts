#!/bin/sh

. ./shared_stats.sh   # musí byť prvé!

CONFIG_FILE="./ping.conf"
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

: "${TARGET:=sme.sk}"
: "${MTU:=1500}"

PAYLOAD=$((MTU - 28))
[ "$PAYLOAD" -lt 0 ] && PAYLOAD=0

LOGFILE="pinglog_$(date +"%Y-%m-%d_%H-%M-%S").txt"

# Farby
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
RESET="\033[0m"

finish() {
    echo ""
    stats_print | tee -a "$LOGFILE"
    kill $PINGPID 2>/dev/null
    exit 0
}

trap finish INT

echo "Cisco‑style ping to $TARGET (MTU=$MTU, payload=$PAYLOAD)"
echo "Logging to $LOGFILE"
echo "Press CTRL+C to stop"
echo ""

# Spustíme ping ako jeden proces (seq sa bude zvyšovať prirodzene)
ping -s "$PAYLOAD" "$TARGET" 2>&1 &
PINGPID=$!

# Čítame výstup ping-u v hlavnom procese (bez subshellu)
while read -r LINE; do
    TS=$(date +"[%Y-%m-%d %H:%M:%S]")

    case "$LINE" in
        *"bytes from"*)
            printf "${GREEN}!${RESET}"
            echo "$TS $LINE" >> "$LOGFILE"

            TIME=$(echo "$LINE" | sed -n 's/.*time=\([0-9.]*\).*/\1/p')
            TIME_INT=${TIME%.*}

            stats_add "$TIME_INT"
            ;;

        *"bad address"*)
            printf "${MAGENTA}?${RESET}"
            echo "$TS bad_address: $LINE" >> "$LOGFILE"
            stats_add "timeout"
            ;;

        *"unknown host"*)
            printf "${MAGENTA}?${RESET}"
            echo "$TS unknown_host: $LINE" >> "$LOGFILE"
            stats_add "timeout"
            ;;

        *"Host is unreachable"*)
            printf "${YELLOW}U${RESET}"
            echo "$TS host_unreachable: $LINE" >> "$LOGFILE"
            stats_add "timeout"
            ;;

        *"Network is unreachable"*)
            printf "${BLUE}N${RESET}"
            echo "$TS network_unreachable: $LINE" >> "$LOGFILE"
            stats_add "timeout"
            ;;

        *"Destination Host Unreachable"*)
            printf "${YELLOW}U${RESET}"
            echo "$TS dest_unreachable: $LINE" >> "$LOGFILE"
            stats_add "timeout"
            ;;

        *"no answer"*)
            printf "${RED}.${RESET}"
            echo "$TS timeout: $LINE" >> "$LOGFILE"
            stats_add "timeout"
            ;;

        *"timeout"*)
            printf "${RED}.${RESET}"
            echo "$TS timeout: $LINE" >> "$LOGFILE"
            stats_add "timeout"
            ;;
    esac

done < /proc/$PINGPID/fd/1
