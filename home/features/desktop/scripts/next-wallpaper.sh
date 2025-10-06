#!/bin/bash

# Configuration
WALLPAPER_DIR="$HOME/Wallpapers"
STATE_FILE="$HOME/.config/hypr/wallpaper_index"
DISPLAY="eDP-1"  # Change to your monitor, use hyprctl monitors to check

# Create Wallpapers directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Get list of wallpapers and check if directory is empty
wallpapers=("$WALLPAPER_DIR"/*)
if [ ${#wallpapers[@]} -eq 0 ] || [ ! -f "${wallpapers[0]}" ]; then
    echo "Error: No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

total_wallpapers=${#wallpapers[@]}

# Read current index or initialize to 0
if [ -f "$STATE_FILE" ]; then
    current_index=$(cat "$STATE_FILE")
else
    current_index=0
fi

# Calculate next index (cycles back to 0 after last wallpaper)
next_index=$(( (current_index + 1) % total_wallpapers ))

# Save the next index for future use
echo "$next_index" > "$STATE_FILE"

# Set the wallpaper using swww
swww img "${wallpapers[$next_index]}" --transition-type=fade --transition-duration=1

# Optional: Send notification
notify-send "Wallpaper Changed" "$(basename "${wallpapers[$next_index]}")" -t 2000 -i "${wallpapers[$next_index]}"
