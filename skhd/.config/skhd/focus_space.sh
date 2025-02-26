#!/bin/bash

# Focus the specified space
yabai -m space --focus $1

# Check if there are any windows in that space
window_count=$(yabai -m query --windows --space $1 | jq '. | length')

# If there are windows, try to focus the first non-floating, non-minimized one
if [ "$window_count" -gt 0 ]; then
    # Get all windows
    windows=$(yabai -m query --windows --space $1)
    
    # Try to find a suitable window to focus
    window_id=$(echo "$windows" | jq -r '.[0].id')
    
    # Focus the window if found
    if [ -n "$window_id" ]; then
        yabai -m window --focus "$window_id"
    fi
fi

exit 0