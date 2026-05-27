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
    exit 0
}

trap finish INT

echo "Cisco‑style ping to $TARGET (MTU=$MTU, payload=$PAYLOAD)"
echo "Logging to $LOGFILE"
echo "Press CTRL+C to stop"
echo ""

while true; do
    RAW=$(ping -c 1 -s "$PAYLOAD" "$TARGET" 2>&1)

    TS=$(date +"[%Y-%m-%d %H:%M:%S]")

    LINE=$(echo "$RAW" | grep "bytes from")

    if [ -n "$LINE" ]; then
        # Cisco znak (farebný)
        printf "${GREEN}!${RESET}"

        # log
        echo "$TS $LINE" >> "$LOGFILE"

        # extrahuj čas
        TIME=$(echo "$LINE" | grep -o "time=[0-9.]*" | cut -d= -f2)
        TIME_INT=${TIME%.*}

        stats_add "$TIME_INT"

    else
        # Rozlíšime typ chyby
        case "$RAW" in
            *"bad address"*)
                printf "${MAGENTA}?${RESET}"
                echo "$TS bad_address: $RAW" >> "$LOGFILE"
                stats_add "timeout"
                ;;

            *"unknown host"*)
                printf "${MAGENTA}?${RESET}"
                echo "$TS unknown_host: $RAW" >> "$LOGFILE"
                stats_add "timeout"
                ;;

            *"Host is unreachable"*)
                printf "${YELLOW}U${RESET}"
                echo "$TS host_unreachable: $RAW" >> "$LOGFILE"
                stats_add "timeout"
                ;;

            *"Network is unreachable"*)
                printf "${BLUE}N${RESET}"
                echo "$TS network_unreachable: $RAW" >> "$LOGFILE"
                stats_add "timeout"
                ;;

            *"Destination Host Unreachable"*)
                printf "${YELLOW}U${RESET}"
                echo "$TS dest_unreachable: $RAW" >> "$LOGFILE"
                stats_add "timeout"
                ;;

            *)
                # timeout alebo iná chyba
                printf "${RED}.${RESET}"
                echo "$TS timeout: $RAW" >> "$LOGFILE"
                stats_add "timeout"
                ;;
        esac
    fi
done
