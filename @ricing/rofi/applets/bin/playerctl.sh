#!/usr/bin/env bash

## Author  : Raiane Oliveira
## Github  : @raiane-oliveira
#
## Applets : Media Player (playerctl)

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements
player_status="$(playerctl status 2>/dev/null)"

if [[ -z "$player_status" || "$player_status" == "No players found" ]]; then
  prompt='Offline'
  mesg="No media player detected"
else
  sep=$'\x1F' # ASCII Unit Separator

  # Usa '$sep' como delimitador para evitar quebra por espaços em nomes/títulos
  IFS="$sep" read -r prompt title length_us < <(playerctl metadata --format "{{artist}}${sep}{{title}}${sep}{{mpris:length}}" 2>/dev/null)

  # Calcula duração só se length_us for um número válido
  if [[ "$length_us" =~ ^[0-9]+$ ]]; then
    length="$(echo "$length_us" | awk '{printf "%d:%02d", $1/60000000, ($1%60000000)/1000000}')"
  else
    length="?:??"
  fi

  # Posição (pode não ser suportada)
  pos_raw="$(playerctl position 2>/dev/null)"
  if [[ "$pos_raw" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    position="$(echo "$pos_raw" | awk '{printf "%d:%02d", $1/60, $1%60}')"
  else
    position="?:??"
  fi

  # Escapa & para Pango markup (usado pelo -markup-rows e -mesg)
  prompt="$(echo "$prompt" | sed 's/&/\&amp;/g')"
  title="$(echo "$title" | sed 's/&/\&amp;/g')"

  mesg="${title:-Desconhecido} :: $position / $length"
fi

if [[ ("$theme" == *'type-1'*) || ("$theme" == *'type-3'*) || ("$theme" == *'type-5'*) ]]; then
  list_col='1'
  list_row='6'
elif [[ ("$theme" == *'type-2'*) || ("$theme" == *'type-4'*) ]]; then
  list_col='6'
  list_row='1'
fi

# Options
layout=$(grep 'USE_ICON' "${theme}" | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
  if [[ "$player_status" == "Playing" ]]; then
    option_1=" Pause"
  else
    option_1=" Play"
  fi
  option_2=" Stop"
  option_3=" Previous"
  option_4=" Next"
  option_5=" Repeat"
  option_6=" Random"
else
  if [[ "$player_status" == "Playing" ]]; then
    option_1=""
  else
    option_1=""
  fi
  option_2=""
  option_3=""
  option_4=""
  option_5=""
  option_6=""
fi

# Toggle Actions
active=''
urgent=''

# Loop (Repeat)
loop_status="$(playerctl loop 2>/dev/null)"
if [[ "$loop_status" == "Track" || "$loop_status" == "Playlist" ]]; then
  active="-a 4"
elif [[ "$loop_status" == "None" ]]; then
  urgent="-u 4"
else
  option_5=" Parsing Error"
fi

# Shuffle (Random)
shuffle_status="$(playerctl shuffle 2>/dev/null)"
if [[ "$shuffle_status" == "On" ]]; then
  [ -n "$active" ] && active+=",5" || active="-a 5"
elif [[ "$shuffle_status" == "Off" ]]; then
  [ -n "$urgent" ] && urgent+=",5" || urgent="-u 5"
else
  option_6=" Parsing Error"
fi

# Rofi CMD
rofi_cmd() {
  rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
    -theme-str 'textbox-prompt-colon {str: "";}' \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    "${active}" "${urgent}" \
    -markup-rows \
    -theme "${theme}"
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

# Execute Command
run_cmd() {
  if [[ "$1" == '--opt1' ]]; then
    playerctl play-pause && notify-send -u low -t 1000 " $(playerctl metadata title)"
  elif [[ "$1" == '--opt2' ]]; then
    playerctl stop
  elif [[ "$1" == '--opt3' ]]; then
    playerctl previous && notify-send -u low -t 1000 " $(playerctl metadata title)"
  elif [[ "$1" == '--opt4' ]]; then
    playerctl next && notify-send -u low -t 1000 " $(playerctl metadata title)"
  elif [[ "$1" == '--opt5' ]]; then
    # Cicla entre None → Track → Playlist → None
    case "$(playerctl loop 2>/dev/null)" in
    None) playerctl loop Track ;;
    Track) playerctl loop Playlist ;;
    Playlist) playerctl loop None ;;
    esac
  elif [[ "$1" == '--opt6' ]]; then
    playerctl shuffle toggle
  fi
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
esac
