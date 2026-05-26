#!/bin/sh

TARGET="sme.sk"
LOGFILE="pinglog_$(date +"%Y-%m-%d_%H-%M-%S").txt"

echo "Starting timestamped ping to $TARGET"
echo "Logging to $LOGFILE"
echo "Press CTRL+C to stop"

# Run ping with timestamps and log it
ping "$TARGET" | awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush(); }' | tee -a "$LOGFILE"

echo ""
echo "Calculating statistics..."

SENT=$(grep -c "icmp_seq" "$LOGFILE")
RECV=$(grep -c "time=" "$LOGFILE")
LOSS=$((100 - (RECV * 100 / SENT)))

MIN=$(grep "time=" "$LOGFILE" | awk -F'time=' '{print $2}' | awk '{print $1}' | sort -n | head -1)
MAX=$(grep "time=" "$LOGFILE" | awk -F'time=' '{print $2}' | awk '{print $1}' | sort -n | tail -1)
AVG=$(grep "time=" "$LOGFILE" | awk -F'time=' '{print $2}' | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')

echo "----- Ping Statistics -----"
echo "Target: $TARGET"
echo "Packets sent: $SENT"
echo "Packets received: $RECV"
echo "Packet loss: $LOSS%"
echo "Min time: $MIN ms"
echo "Max time: $MAX ms"
echo "Avg time: $AVG ms"
echo "---------------------------"
