#!/bin/sh

options=(
" DuckDuckGo
 Youtube
 Standard Notes
 Github
 Piped
󰊿 DeepL
 Reddit")

choice=$(echo "$options" | rofi -dmenu -p "Bookmarks:" -theme-str 'window {width: 600px;}')


case "$choice" in
" DuckDuckGo")
    choice="https://duckduckgo.com/"
    ;;
" Github")
    choice="https://github.com/"
    ;;
" Youtube")
    choice="https://youtube.com/"
    ;;
" Standard Notes")
    choice="https://app.standardnotes.com/"
    ;;
"󰊿 DeepL")
    choice="https://www.deepl.com/translator"
    ;;
" Piped")
    choice="https://piped.video"
    ;;
" Reddit")
    choice="https://www.reddit.com/"
    ;;
*)
	exit 1
	;;
esac

librewolf "$choice"

