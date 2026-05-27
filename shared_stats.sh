#!/bin/sh

# Extended histogram for slow networks (GPRS/EDGE)

STATS_COUNT=0
STATS_SUM=0
STATS_MIN=""
STATS_MAX=""

# 11 bucketov:
# 1: 0–49
# 2: 50–99
# 3: 100–199
# 4: 200–399
# 5: 400–799
# 6: 800–1599
# 7: 1600–3199
# 8: 3200–6399
# 9: 6400–12799
# 10: 12800+
# 11: timeout
STATS_BUCKETS="0 0 0 0 0 0 0 0 0 0 0"

stats_add() {
    value=$1

    # 1. Determine bucket safely
    case "$value" in
        ''|*[!0-9]*)
            idx=11 ;;  # timeout / invalid
        *)
            if   [ "$value" -lt 50 ]; then idx=1
            elif [ "$value" -lt 100 ]; then idx=2
            elif [ "$value" -lt 200 ]; then idx=3
            elif [ "$value" -lt 400 ]; then idx=4
            elif [ "$value" -lt 800 ]; then idx=5
            elif [ "$value" -lt 1600 ]; then idx=6
            elif [ "$value" -lt 3200 ]; then idx=7
            elif [ "$value" -lt 6400 ]; then idx=8
            elif [ "$value" -lt 12800 ]; then idx=9
            else idx=10
            fi
            ;;
    esac

    # 2. Update numeric stats
    case "$value" in
        ''|*[!0-9]*)
            ;; # skip
        *)
            STATS_COUNT=$((STATS_COUNT + 1))
            STATS_SUM=$((STATS_SUM + value))

            [ -z "$STATS_MIN" ] || [ "$value" -lt "$STATS_MIN" ] && STATS_MIN=$value
            [ -z "$STATS_MAX" ] || [ "$value" -gt "$STATS_MAX" ] && STATS_MAX=$value
            ;;
    esac

    # 3. Update bucket
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

    labels="0-49 50-99 100-199 200-399 400-799 800-1599 1600-3199 3200-6399 6400-12799 12800+ timeout"
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

        printf "%-12s | %s\n" "$label" "$bar"

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
