#!/bin/sh
# polybar updates script — ArchDroid
if ! updates=$(checkupdates 2> /dev/null | wc -l); then
    updates=0
fi
if [ "$updates" -ge 0 ]; then
    echo "UPDATES: $updates"
else
    echo "UPDATES: N/A"
fi
