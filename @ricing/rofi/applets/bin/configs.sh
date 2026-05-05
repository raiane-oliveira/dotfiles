#!/usr/bin/env bash

## Author  : Raiane Oliveira
## Github  : @raiane-oliveira
#
## Applets : Edit config files for Hyprland

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements
if [[ ("$theme" == *'type-1'*) || ("$theme" == *'type-3'*) || ("$theme" == *'type-5'*) ]]; then
  list_col='1'
  list_row='8'
elif [[ ("$theme" == *'type-2'*) || ("$theme" == *'type-4'*) ]]; then
  list_col='8'
  list_row='1'
fi

# Options
layout=$(grep 'USE_ICON' "${theme}" | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
  option_1="󰕮 Autostart"
  option_2="󰌌 Keybindings"
  option_3="󰕈 Environment Variables"
  option_4="󰍽 Input"
  option_5="󰏘 Look and Feel"
  option_6="󰍹 Monitors"
  option_7="󰖯 Windows"
  option_8="󱗼 General"
else
  option_1="󰕮 "
  option_2="󰌌 "
  option_3="󰕈 "
  option_4="󰍽 "
  option_5="󰏘 "
  option_6="󰍹 "
  option_7="󰖯 "
  option_8="󱗼 "
fi

# Toggle Actions
active=''
urgent=''

# Rofi CMD
rofi_cmd() {
  prompt="Configs"
  rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
    -theme-str 'textbox-prompt-colon {str: "";}' \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    "${active}" "${urgent}" \
    -markup-rows \
    -theme "${theme}"
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6\n$option_7\n$option_8" | rofi_cmd
}

# Execute Command
run_cmd() {
  configDir="$HOME/.config/hypr"
  configPath="hyprland.conf"

  if [[ "$1" == '--opt1' ]]; then
    configPath="modules/autostart.conf"
  elif [[ "$1" == '--opt2' ]]; then
    configPath="modules/binds.conf"
  elif [[ "$1" == '--opt3' ]]; then
    configPath="modules/env.conf"
  elif [[ "$1" == '--opt4' ]]; then
    configPath="modules/input.conf"
  elif [[ "$1" == '--opt5' ]]; then
    configPath="modules/look-and-feel.conf"
  elif [[ "$1" == '--opt6' ]]; then
    configPath="modules/monitors.conf"
  elif [[ "$1" == '--opt7' ]]; then
    configPath="modules/windows.conf"
  fi

  kitty --title "Editing $configPath" -- bash -c "nvim $configDir/$configPath"

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
  run_cmd --opt6
  ;;
$option_8)
  run_cmd
  ;;
esac
