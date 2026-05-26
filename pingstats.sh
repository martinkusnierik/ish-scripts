#!/bin/sh

. ./shared_stats.sh
stats_enable_trap

CONFIG_FILE="./ping.conf"
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"
: "${TARGET:=sme.sk}"

LOGFILE="pinglog_$(date +"%Y-%m-%d_%H-%M-%S").txt"

echo "Timestamped ping to $TARGET"
echo "Logging to $LOGFILE"
echo "Press CTRL+C to stop"

while read -r line; do
    echo "$(date +"[%Y-%m-%d %H:%M:%S]") $line" | tee -a "$LOGFILE"

    TIME=$(echo "$line" | grep -o "time=[0-9.]*" | cut -d= -f2)
    TIME_INT=${TIME%.*}

    [ -n "$TIME_INT" ] && stats_add "$TIME_INT"

done < <(ping "$TARGET")
