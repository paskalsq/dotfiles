#!/bin/bash

SINK="56"
PORT_A="analog-output-headphones"
PORT_B="analog-output-headphones-2"

# Get acitve port
CURRENT_PORT=$(pactl list sinks | awk -v sink="#$SINK" '/Sink / {p=($0 ~ sink)} p && /Active Port:/ {print $3; exit}')

# Toggle
if [ "$CURRENT_PORT" == "$PORT_A" ]; then
    pactl set-sink-port "$SINK" "$PORT_B"
elif [ "$CURRENT_PORT" == "$PORT_B" ]; then
    pactl set-sink-port "$SINK" "$PORT_A"
fi
