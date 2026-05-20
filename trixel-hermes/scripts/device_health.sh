#!/bin/bash
BATTERY_INFO=$(termux-battery-status)
PERCENT=$(echo "$BATTERY_INFO" | grep "percentage" | awk '{print $2}' | tr -d ',')
STATUS=$(echo "$BATTERY_INFO" | grep "status" | awk '{print $2}' | tr -d '"' | tr -d ',')

echo "Device Health Status:"
echo "Battery: $PERCENT% ($STATUS)"
if [ "$PERCENT" -lt 20 ]; then
    echo "WARNING: Low battery. Recommend pausing high-intensity AI tasks."
fi
