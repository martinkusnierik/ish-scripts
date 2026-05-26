stats_add() {
    value=$1

    # Ak nie je číslo → timeout bucket (6)
    case "$value" in
        ''|*[!0-9]*)
            idx=6
            ;;
        *)
            # Je to číslo → normálne bucketovanie
            if   [ "$value" -lt 20 ]; then idx=1
            elif [ "$value" -lt 40 ]; then idx=2
            elif [ "$value" -lt 60 ]; then idx=3
            elif [ "$value" -lt 80 ]; then idx=4
            elif [ "$value" -lt 100 ]; then idx=5
            else idx=6
            fi
            ;;
    esac

    # Aktualizácia min/max/sum/count len ak je to číslo
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

    # Bezpečná aktualizácia bucketov
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
