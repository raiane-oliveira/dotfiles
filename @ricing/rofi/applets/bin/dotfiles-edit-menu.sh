#!/usr/bin/env bash

## Author  : Raiane Oliveira
## Github  : @raiane-oliveira
#
## Applets : Edit dotfiles

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
  option_1="󱧶 Dotfiles"
  option_2="󰄛 Rofi"
  option_3=" Hyprland"
  option_4="󰓫 Waybar"
  option_5="󰂚 Swaync"
  option_6="󰍁 Hyprlock"
  option_7=" Neovim"
  option_8="󰈺 Fish"
else
  option_1="󱧶 "
  option_2="󰄛 "
  option_3=" "
  option_4="󰓫 "
  option_5="󰂚 "
  option_6="󰍁 "
  option_7=" "
  option_8="󰈺 "
fi

# Options Rofi
if [[ "$layout" == 'NO' ]]; then
  rofi_option_1="󱓞 Launcher"
  rofi_option_2="󰜬 Applets"
  rofi_option_3="󰐥 Powermenu"
else
  rofi_option_1="󰍹 "
  rofi_option_2="󰖯 "
  rofi_option_3="󱗼 "
fi

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

run_config_rofi() {
  echo -e "$rofi_option_1\n$rofi_option_2\n$rofi_option_3" | rofi_cmd "Rofi" "󰄛"
}

run_config_rofi_menu() {
  configDir="$HOME/.config/rofi"
  configFile="launchers/current"
  currentTheme="$configDir/launchers/type-6/style-5.rasi"

  local chosen="$(run_config_rofi)"
  if [[ -z "$chosen" ]]; then
    exit 0
  fi

  case ${chosen} in
  $rofi_option_1)
    ;;
  $rofi_option_2)
    configFile="applets/bin"
    currentTheme="$configDir/applets/type-5/style-1.rasi"
    ;;
  $rofi_option_3)
    configFile="powermenu/current"
    currentTheme="$configDir/powermenu/type-5/style-3.rasi"
    ;;
  esac

  exec kitty --title "Editing $configDir/$configFile" -- bash -c "nvim $configDir/$configFile $currentTheme"
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6\n$option_7\n$option_8" | rofi_cmd
}

# Execute Command
run_cmd() {
  configDir="$HOME/dotfiles"
  configFile=""

  if [[ "$1" == '--opt2' ]]; then
    run_config_rofi_menu
    exit 0
  elif [[ "$1" == '--opt3' ]]; then
    exec "$HOME/dotfiles/@ricing/rofi/applets/bin/configs.sh"
  elif [[ "$1" == '--opt4' ]]; then
    configFile="@ricing/waybar/config.jsonc"
    currentTheme="$configDir/@ricing/waybar/style.css"
    exec kitty --title "Editing $configFile" -- bash -c "nvim $configDir/$configFile $currentTheme"
  elif [[ "$1" == '--opt5' ]]; then
    configFile="@ricing/swaync/config.json"
    currentTheme="$configDir/@ricing/swaync/style.css"
    exec kitty --title "Editing $configFile" -- bash -c "nvim $configDir/$configFile $currentTheme"
  elif [[ "$1" == '--opt6' ]]; then
    configFile="@ricing/hyprlock/current.conf"
  elif [[ "$1" == '--opt7' ]]; then
    configFile="nvim"
  elif [[ "$1" == '--opt8' ]]; then
    configFile="fish"
  fi

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
esac
