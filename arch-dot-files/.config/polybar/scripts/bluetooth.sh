#!/usr/bin/env bash
# bluetooth.sh — Polybar module for Bluetooth status
bluetoothctl show 2>/dev/null | grep -q "Powered: yes" || { echo "  "; exit 0; }
device_count=$(bluetoothctl devices Connected 2>/dev/null | wc -l)
if [ "$device_count" -gt 0 ]; then
    echo "   $device_count  "
else
    echo "    "
fi
