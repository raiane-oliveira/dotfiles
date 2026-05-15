#!/bin/bash

## Author  : Raiane Oliveira
## Github  : @raiane-oliveira
#
## Applets : Change wallpaper (swww)

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Directory where wallpapers are stored
WALL_DIR="$HOME/Pictures/Wallpapers"

# Current directory (to cd back to)
CMD="$(pwd)"

cd $WALL_DIR || exit

# Handle spaces in filenames
IFS=$'\n'

# Grab the user-selected wallpaper using rofi
SELECTED_WALL=$(
  for a in *.jpg *.png *.jpeg; do echo -en "$a\0icon\x1f$a\n"; done | rofi \
    -dmenu \
    -theme "$theme" \
    -show-icons \
    -p "󰥷" \
    -theme-str 'configuration {
  kb-remove-char-back: "BackSpace";
  kb-row-up: "Up,Control+k,Shift+Tab,Shift+ISO_Left_Tab";
  kb-row-down: "Down,Control+j";
  kb-move-char-back: "Left,Control+h";
  kb-move-char-forward: "Right,Control+l";
}' \
    -theme-str 'window { width: 900px; height: 500px; border-radius: 15px; }' \
    -theme-str 'mainbox { orientation: horizontal; children: [ "left-pane", "right-box" ]; spacing: 20px; }' \
    -theme-str 'left-pane { width: 500px; expand: false; children: [ "icon-current-entry" ]; background-color: transparent; }' \
    -theme-str 'icon-current-entry { size: 500px; horizontal-align: 0.5; vertical-align: 0.25; background-color: transparent; }' \
    -theme-str 'right-box { orientation: vertical; children: [ "inputbar", "listview" ]; expand: true; }' \
    -theme-str 'inputbar { children: [ "prompt", "entry" ]; spacing: 10px; padding: 15px 10px; background-color: transparent; }' \
    -theme-str 'entry { placeholder: "Pesquisar..."; border-radius: 3px; cursor: text; text-color: @foreground; background-color: @background-alt; padding: 10px 14px; }' \
    -theme-str 'listview { columns: 2; lines: 10; expand: true; padding: 10px; }' \
    -theme-str 'element { orientation: horizontal; padding: 2px 8px; spacing: 10px; }' \
    -theme-str 'element-icon { size: 48px; background-color: transparent; border: 0px; }' \
    -theme-str 'textbox-prompt-colon { str: ":"; }' \
    -theme-str 'prompt { background-color: @urgent; border-radius: 3px; padding: 10px 14px; }'
)

# If not empty, pass to walset
if [ -n "$SELECTED_WALL" ]; then
  walset "$SELECTED_WALL"
fi

# Go back to where you came from
cd "$CMD" || exit
