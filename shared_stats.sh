#!/bin/sh

# Shared statistics module with safe histogram

STATS_COUNT=0
STATS_SUM=0
STATS_MIN=""
STATS_MAX=""
STATS_BUCKETS="0 0 0 0 0 0"   # 6 bucketov: 0–19, 20–39, 40–59, 60–79, 80–99, 100+/timeout

stats_add() {
    value=$1

    # 1. Urči bucket bezpečne
    case "$value" in
        ''|*[!0-9]*)
            idx=6 ;;  # timeout / neplatná hodnota
        *)
            if   [ "$value" -lt 20 ]; then idx=1
            elif [ "$value" -lt 40 ]; then idx=2
            elif [ "$value" -lt 60 ]; then idx=3
            elif [ "$value" -lt 80 ]; then idx=4
            elif [ "$value" -lt 100 ]; then idx=5
            else idx=6
            fi
            ;;
    esac

    # 2. Aktualizuj štatistiky len ak je to číslo
    case "$value" in
        ''|*[!0-9]*)
            ;; # preskoč
        *)
            STATS_COUNT=$((STATS_COUNT + 1))
            STATS_SUM=$((STATS_SUM + value))

            [ -z "$STATS_MIN" ] || [ "$value" -lt "$STATS_MIN" ] && STATS_MIN=$value
            [ -z "$STATS_MAX" ] || [ "$value" -gt "$STATS_MAX" ] && STATS_MAX=$value
            ;;
    esac

    # 3. Bezpečne aktualizuj bucket
    old=$(echo "$STATS_BUCKETS" | cut -d' ' -f$idx)
    new=$((old + 1))

    STATS_BUCKETS=$(echo "$STATS_BUCKETS" | awk -v i=$idx -v v=$new '
        {
            for (n=1; n<=NF; n++) {
                if (n==i) printf "%d ", v;
                else printf "%s ", $n;
            }
        }')
}

stats_print_histogram() {
    echo ""
    echo "Latency histogram (ms)"

    labels="0–19 20–39 40–59 60–79 80–99 100+"
    max_bucket=$(echo "$STATS_BUCKETS" | tr ' ' '\n' | sort -nr | head -1)

    i=1
    for label in $labels; do
        count=$(echo "$STATS_BUCKETS" | cut -d' ' -f$i)

        if [ "$max_bucket" -gt 0 ]; then
            bar_len=$((count * 30 / max_bucket))
        else
            bar_len=0
        fi

        bar=$(printf "%${bar_len}s" | tr ' ' '#')

        printf "%-6s | %s\n" "$label" "$bar"

        i=$((i+1))
    done
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

    stats_print_histogram
}
