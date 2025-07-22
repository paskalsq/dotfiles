#!/bin/bash

SINK="56"
PORT_A="analog-output-headphones"

CURRENT_PORT=$(pactl list sinks | awk -v sink="#$SINK" '/Sink / {p=($0 ~ sink)} p && /Active Port:/ {print $3; exit}')
if [ "$CURRENT_PORT" == "$PORT_A" ]; then
    printf '{"text": """, "icon": ""}\n'
else
    printf '{"text": "󰓃", "icon": "󰓃"}\n'
fi

