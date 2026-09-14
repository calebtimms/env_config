while true; do
    printf '%s  ' "$(date '+%H:%M:%S')"
    solaar show 2>/dev/null |
        grep 'Battery:' |
        tail -1
    sleep 300
done
