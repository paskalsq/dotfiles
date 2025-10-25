#/bin/bash

if playerctl status | grep -q "Playing"; then
  playerctl play-pause
  PLAYING=1
else
  PLAYING=0
fi

hyprlock -q

if [ "$PLAYING" -eq 1 ]; then
  playerctl play-pause
fi
