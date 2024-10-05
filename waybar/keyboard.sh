#!/bin/bash

# ID клавиатуры
DEVICE_ID="5af12c994b90"

# Получить текущее состояние устройства
DEVICE_STATUS=$(hyprctl devices | grep -A 10 "$DEVICE_ID" | grep "active: yes")

# Переключить состояние клавиатуры
if [ -n "$DEVICE_STATUS" ]; then
  # Отключить клавиатуру
  hyprctl keyword input:disable "$DEVICE_ID"
else
  # Включить клавиатуру
  hyprctl keyword input:enable "$DEVICE_ID"
fi

