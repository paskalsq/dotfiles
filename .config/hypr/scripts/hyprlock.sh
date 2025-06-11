#!/bin/bash

# Check if cmus is playing and pause it
if cmus-remote -Q | grep -q "status playing"; then
    cmus-remote -u
    WAS_PLAYING=1
else
    WAS_PLAYING=0
fi

# Lock screen
hyprlock --immediate

# Resume if was playing
if [ "$WAS_PLAYING" -eq 1 ]; then
    cmus-remote -u
fi
