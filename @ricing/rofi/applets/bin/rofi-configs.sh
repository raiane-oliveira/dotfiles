#!/usr/bin/env bash

## Author  : Raiane Oliveira
## Github  : @raiane-oliveira
#
## Applets : Edit config files for Rofi Menus

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
  option_1="󱓞 Launcher"
  option_2="󰜬 Applets"
  option_3="󰐥 Powermenu"
else
  option_1="󱓞"
  option_2="󰜬"
  option_3="󰐥"
fi

# Toggle Actions
active=''
urgent=''

# Rofi CMD
rofi_cmd() {
  prompt="Rofi"
  rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
    -theme-str 'textbox-prompt-colon {str: "󰄛";}' \
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
  configDir="$HOME/dotfiles/@ricing/rofi"
  configFile="launchers/current"
  currentTheme="$configDir/launchers/type-6/style-5.rasi"

  if [[ "$1" == '--opt1' ]]; then
    currentDirectory="$configDir/launchers"
  elif [[ "$1" == '--opt2' ]]; then
    configFile="applets/bin"
    currentDirectory="$configDir/applets"

    source "$currentDirectory/shared/theme.bash"
    currentTheme="$type/$style"
  elif [[ "$1" == '--opt3' ]]; then
    configFile="powermenu/current"
    currentTheme="$configDir/powermenu/type-5/style-3.rasi"
    currentDirectory="$configDir/powermenu"
  fi

  cd "$currentDirectory" || exit
  exec kitty --title "Editing $(shorten_path "$configDir/$configFile")" -- bash -c "nvim $configDir/$configFile $currentTheme"
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
