#!/bin/sh

# Shared statistics module

STATS_COUNT=0
STATS_SUM=0
STATS_MIN=""
STATS_MAX=""

stats_add() {
    value=$1

    # Ignore timeouts (value = 0)
    if [ "$value" -eq 0 ]; then
        return
    fi

    STATS_COUNT=$((STATS_COUNT + 1))
    STATS_SUM=$((STATS_SUM + value))

    if [ -z "$STATS_MIN" ] || [ "$value" -lt "$STATS_MIN" ]; then
        STATS_MIN=$value
    fi

    if [ -z "$STATS_MAX" ] || [ "$value" -gt "$STATS_MAX" ]; then
        STATS_MAX=$value
    fi
}

stats_print() {
    echo ""
    echo "----- Statistics -----"
    echo "Samples: $STATS_COUNT"

    if [ "$STATS_COUNT" -gt 0 ]; then
        AVG=$((STATS_SUM / STATS_COUNT))
        echo "Min: ${STATS_MIN} ms"
        echo "Max: ${STATS_MAX} ms"
        echo "Avg: ${AVG} ms"
    else
        echo "No valid samples."
    fi

    echo "----------------------"
}

stats_enable_trap() {
    trap 'stats_print; exit 0' INT
}
