#!/usr/bin/env bash

## Author  : Raiane Oliveira
## Github  : @raiane-oliveira
#
## Applets : Edit dotfiles

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Current directory (to cd back to)
CMD="$(pwd)"

# Theme Elements
if [[ ("$theme" == *'type-1'*) || ("$theme" == *'type-3'*) || ("$theme" == *'type-5'*) ]]; then
  list_col='1'
  list_row='9'
elif [[ ("$theme" == *'type-2'*) || ("$theme" == *'type-4'*) ]]; then
  list_col='9'
  list_row='1'
fi

# Options
layout=$(grep 'USE_ICON' "${theme}" | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
  option_1="󱧶 Dotfiles"
  option_2="󰄛 Rofi"
  option_3=" Hyprland"
  option_4="󰓫 Waybar"
  option_5="󰂚 Swaync"
  option_6="󰍁 Hyprlock"
  option_7=" Neovim"
  option_8="󰈺 Fish"
  option_9="󰝆 RaianeFlix"
else
  option_1="󱧶"
  option_2="󰄛"
  option_3=""
  option_4="󰓫"
  option_5="󰂚"
  option_6="󰍁"
  option_7=""
  option_8="󰈺"
  option_9="󰝆"
fi

# Utility function
shorten_path() {
  echo "${1/#$HOME/\~}"
}

# Rofi CMD
rofi_cmd() {
  local prompt=${1:-"Configs"}
  local icon=${2:-"󱁻"}

  rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
    -theme-str "textbox-prompt-colon {str: \"$icon\";}" \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    -markup-rows \
    -theme "${theme}"
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6\n$option_7\n$option_8\n$option_9" | rofi_cmd
}

# Execute Command
run_cmd() {
  configDir="$HOME/dotfiles"
  configFile="$HOME/dotfiles"

  if [[ "$1" == '--opt2' ]]; then
    exec "$HOME/dotfiles/@ricing/rofi/applets/bin/rofi-configs.sh"
  elif [[ "$1" == '--opt3' ]]; then
    exec "$HOME/dotfiles/@ricing/rofi/applets/bin/hypr-configs.sh"
  elif [[ "$1" == '--opt4' ]]; then
    configFile="$configDir/@ricing/waybar/config.jsonc"
    currentTheme="$configDir/@ricing/waybar/style.css"
    currentDirectory="$configDir/@ricing/waybar"

    cd "$currentDirectory" || exit
    exec kitty --title "Editing $(shorten_path "$configFile")" -- bash -c "nvim $configFile $currentTheme"
  elif [[ "$1" == '--opt5' ]]; then
    configFile="$configDir/@ricing/swaync/config.json"
    currentTheme="$configDir/@ricing/swaync/style.css"
    currentDirectory="$configDir/@ricing/swaync"

    cd "$currentDirectory" || exit
    exec kitty --title "Editing $(shorten_path "$configFile")" -- bash -c "nvim $configFile $currentTheme"
  elif [[ "$1" == '--opt6' ]]; then
    configFile="$configDir/@ricing/hyprlock/current.conf"
  elif [[ "$1" == '--opt7' ]]; then
    configDir="$configDir/nvim"
    configFile=""
  elif [[ "$1" == '--opt8' ]]; then
    configDir="$configDir/fish"
    configFile="$configDir/config.fish"
  elif [[ "$1" == '--opt9' ]]; then
    exec "$HOME/dotfiles/@ricing/rofi/applets/bin/raianeflix-configs.sh"
  fi

  cd "$configDir" || exit
  kitty --title "Editing $(shorten_path "$configFile")" -- bash -c "nvim $configFile $currentTheme"

}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
$option_1)
  run_cmd --opt1
  ;;
$option_2)
  run_cmd --opt2
  ;;
$option_3)
  run_cmd --opt3
  ;;
$option_4)
  run_cmd --opt4
  ;;
$option_5)
  run_cmd --opt5
  ;;
$option_6)
  run_cmd --opt6
  ;;
$option_7)
  run_cmd --opt7
  ;;
$option_8)
  run_cmd --opt8
  ;;
$option_9)
  run_cmd --opt9
  ;;
esac

# Go back to where you came from
cd "$CMD" || exit
