#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Power Menu
#
## Available Styles
#
## style-1   style-2   style-3   style-4   style-5

# Current Theme
dir="$HOME/.config/rofi/powermenu/type-5"
theme='style-3'

# CMDs
lastlogin="$(last $USER | head -n1 | tr -s ' ' | cut -d' ' -f5,6,7)"
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(hostname)

# Options
hibernate=''
shutdown=''
reboot=''
lock=''
suspend=''
logout=''
yes=''
no=''

# Rofi CMD
rofi_cmd() {
  rofi -dmenu \
    -p " $USER" \
    -mesg " Last Login: $lastlogin |  Uptime: $uptime" \
    -theme ${dir}/${theme}.rasi
}

# Confirmation CMD
confirm_cmd() {
  local action_label="$1"
  rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
    -theme-str 'mainbox {children: [ "message", "listview" ];}' \
    -theme-str 'listview {columns: 2; lines: 1;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'textbox {horizontal-align: 0.5;}' \
    -dmenu \
    -p 'Confirmation' \
    -mesg "Are you sure you want to $action_label?" \
    -theme ${dir}/${theme}.rasi
}

# Ask for confirmation
confirm_exit() {
  local action_label="$1"
  echo -e "$yes\n$no" | confirm_cmd "$action_label"
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$lock\n$suspend\n$logout\n$hibernate\n$reboot\n$shutdown" | rofi_cmd
}

# Map chosen option to human-readable label
get_action_label() {
  local chosen="$1"
  if [[ "$chosen" == "$shutdown" ]]; then
    echo "Shutdown"
  elif [[ "$chosen" == "$reboot" ]]; then
    echo "Reboot"
  elif [[ "$chosen" == "$hibernate" ]]; then
    echo "Hibernate"
  elif [[ "$chosen" == "$suspend" ]]; then
    echo "Suspend"
  elif [[ "$chosen" == "$logout" ]]; then
    echo "Logout"
  elif [[ "$chosen" == "$lock" ]]; then
    echo "Lock"
  else
    echo "$chosen"
  fi
}

# Execute Command
run_cmd() {
  local action_label="$2"
  selected="$(confirm_exit "$action_label")"
  if [[ "$selected" == "$yes" ]]; then
    if [[ $1 == '--shutdown' ]]; then
      systemctl poweroff
    elif [[ $1 == '--reboot' ]]; then
      systemctl reboot
    elif [[ $1 == '--hibernate' ]]; then
      systemctl hibernate
    elif [[ $1 == '--suspend' ]]; then
      mpc -q pause
      amixer set Master mute
      systemctl suspend
    elif [[ $1 == '--logout' ]]; then
      if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
        openbox --exit
      elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
        bspc quit
      elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
        i3-msg exit
      elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
        qdbus org.kde.ksmserver /KSMServer logout 0 0 0
      else
        command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit
      fi
    fi
  else
    exit 0
  fi
}

# Actions
chosen="$(run_rofi)"
action_label="$(get_action_label "$chosen")"

case ${chosen} in
$shutdown)
  run_cmd --shutdown "$action_label"
  ;;
$reboot)
  run_cmd --reboot "$action_label"
  ;;
$hibernate)
  run_cmd --hibernate "$action_label"
  ;;
$lock)
  selected="$(confirm_exit "$action_label")"
  if [[ "$selected" == "$yes" ]]; then
    if [[ -x '/usr/bin/betterlockscreen' ]]; then
      betterlockscreen -l
    elif [[ -x '/usr/bin/i3lock' ]]; then
      i3lock
    elif [[ -x '/usr/bin/hyprlock' ]]; then
      loginctl lock-session
    fi
  fi
  ;;
$suspend)
  run_cmd --suspend "$action_label"
  ;;
$logout)
  run_cmd --logout "$action_label"
  ;;
esac
