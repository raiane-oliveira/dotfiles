#!/usr/bin/env bash

## Author  : Raiane Oliveira
## Github  : @raiane-oliveira
#
## Applets : Edit config files for Plex, Radarr, Sonarr, qBittorrent, etc.

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements
if [[ ("$theme" == *'type-1'*) || ("$theme" == *'type-3'*) || ("$theme" == *'type-5'*) ]]; then
  list_col='1'
  list_row='5'
elif [[ ("$theme" == *'type-2'*) || ("$theme" == *'type-4'*) ]]; then
  list_col='5'
  list_row='1'
fi

# Options
layout=$(grep 'USE_ICON' "${theme}" | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
  option_1="󰡨 Docker"
  option_2="󰍇 qBittorrent"
  option_3="󰹢 Jackett"
else
  option_1="󰡨"
  option_2="󰍇"
  option_3="󰹢"
fi

# Toggle Actions
active=''
urgent=''

# Rofi CMD
rofi_cmd() {
  prompt="RaianeFlix"
  rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
    -theme-str 'textbox-prompt-colon {str: "󰝆";}' \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    "${active}" "${urgent}" \
    -markup-rows \
    -theme "${theme}"
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$option_1\n$option_2\n$option_3" | rofi_cmd
}

# Execute Command
run_cmd() {
  configDir="$HOME/.config"

  if [[ "$1" == '--opt1' ]]; then
    configDir="/home/media/RaianeFlix/docker"
    configFile="docker-compose.yml"
  elif [[ "$1" == '--opt2' ]]; then
    configDir="$configDir/qBittorrent"
    configFile="qBittorrent.conf"
  elif [[ "$1" == '--opt3' ]]; then
    configDir="$configDir/qBittorrent/qBittorrent/nova3/engines"
    configFile="jackett.json"
  fi

  cd "$configDir" || exit
  kitty --title "Editing $configFile" -- bash -c "nvim $configDir/$configFile"
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
esac
