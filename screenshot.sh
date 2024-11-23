#!/bin/bash
spectacle -r -o "$HOME/Pictures/Screenshots/screen-$(date +%s).png"
notify-send "Скриншот" "Сохранен в ~/Pictures/Screenshots"

