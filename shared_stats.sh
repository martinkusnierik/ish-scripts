#!/bin/sh

STATS_COUNT=0
STATS_SUM=0
STATS_MIN=""
STATS_MAX=""

# Buckets:
# 1: 0–25
# 2: 26–49
# 3: 50–99
# 4: 100–199
# 5: 200–399
# 6: 400–799
# 7: 800–1599
# 8: 1600–3199
# 9: 3200–6399
# 10: timeout
STATS_BUCKETS="0 0 0 0 0 0 0 0 0 0"

stats_add() {
    value=$1

    case "$value" in
        ''|*[!0-9]*)
            idx=10 ;;  # timeout
        *)
            if   [ "$value" -le 25 ]; then idx=1
            elif [ "$value" -le 49 ]; then idx=2
            elif [ "$value" -le 99 ]; then idx=3
            elif [ "$value" -le 199 ]; then idx=4
            elif [ "$value" -le 399 ]; then idx=5
            elif [ "$value" -le 799 ]; then idx=6
            elif [ "$value" -le 1599 ]; then idx=7
            elif [ "$value" -le 3199 ]; then idx=8
            elif [ "$value" -le 6399 ]; then idx=9
            else idx=10
            fi
            ;;
    esac

    case "$value" in
        ''|*[!0-9]*)
            ;;
        *)
            STATS_COUNT=$((STATS_COUNT + 1))
            STATS_SUM=$((STATS_SUM + value))

            [ -z "$STATS_MIN" ] || [ "$value" -lt "$STATS_MIN" ] && STATS_MIN=$value
            [ -z "$STATS_MAX" ] || [ "$value" -gt "$STATS_MAX" ] && STATS_MAX=$value
            ;;
    esac

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

    labels="0-25 26-49 50-99 100-199 200-399 400-799 800-1599 1600-3199 3200-6399 timeout"
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
