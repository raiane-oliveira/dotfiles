#!/usr/bin/env bash

## Author  : Raiane Oliveira
## Github  : @raiane-oliveira
#
## Applets : Manager docker containers from RaianeFlix

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Docker Compose project path
COMPOSE_FILE="/home/media/RaianeFlix/docker/docker-compose.yml"
COMPOSE_CMD="docker compose -f $COMPOSE_FILE"

# Theme Elements
_get_container_info() {
  local info
  info="$($COMPOSE_CMD ps --format 'table {{.Name}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null | tail -n +2)"

  if [[ -z "$info" ]]; then
    echo "Nenhum container encontrado"
  else
    echo "$info"
  fi
}

_running_count() {
  $COMPOSE_CMD ps --status running -q 2>/dev/null | wc -l | tr -d ' '
}

_total_count() {
  $COMPOSE_CMD ps -a -q 2>/dev/null | wc -l | tr -d ' '
}

running="$(_running_count)"
total="$(_total_count)"

prompt='RaianeFlix'
mesg="Containers: ${running} rodando / ${total} total"

# Layout columns/rows
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
  option_1=" Iniciar"
  option_2=" Parar"
  option_3=" Informações"
  option_4=" Armazenamento"
  option_5="󰝰 Abrir diretório"
else
  option_1=""
  option_2=""
  option_3=""
  option_4=""
  option_5="󰝰"
fi

# Rofi CMD
rofi_cmd() {
  rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
    -theme-str 'textbox-prompt-colon {str: "󰡨";}' \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    -markup-rows \
    -theme "${theme}"
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

# Show container info in Rofi
show_info() {
  local info lines line_count

  info="$(_get_container_info)"
  line_count="$(echo "$info" | grep -c .)"

  # Se não há containers, exibe menu mínimo com 1 linha
  if [[ "$line_count" -eq 0 || "$info" == "Nenhum container encontrado" ]]; then
    line_count=5
    info="Nenhum container rodando"
  fi

  chosen_line="$(echo "$info" | rofi \
    -theme-str "listview {columns: 1; lines: ${line_count};}" \
    -theme-str 'textbox-prompt-colon {str: "󰡨";}' \
    -dmenu \
    -p "Containers" \
    -mesg "Clique em um container para ver os logs" \
    -no-custom \
    -theme "${theme}")"

  [[ -z "$chosen_line" ]] && return

  # Extrai o nome do container (primeira coluna da linha selecionada)
  container_name="$(echo "$chosen_line" | awk '{print $1}')"

  [[ -z "$container_name" ]] && return

  kitty --title "logs:${container_name}" -- docker logs -f --tail 200 "${container_name}"
}

# Execute Command
run_cmd() {
  if [[ "$1" == '--opt1' ]]; then

    notify-send -u low -t 2000 "RaianeFlix" "Iniciando containers..." -i info
    $COMPOSE_CMD up -d --no-recreate 2>/dev/null &&
      notify-send -u low -t 2000 "RaianeFlix" "Containers iniciados com sucesso" -i dialog-ok ||
      notify-send -u critical -t 3000 "RaianeFlix" "Erro ao iniciar containers" -i error

  elif [[ "$1" == '--opt2' ]]; then
    notify-send -u low -t 2000 "RaianeFlix" "Parando containers..." -i info
    $COMPOSE_CMD stop 2>/dev/null &&
      notify-send -u low -t 2000 "RaianeFlix" "Containers parados com sucesso" -i dialog-ok ||
      notify-send -u critical -t 3000 "RaianeFlix" "Erro ao parar containers" -i error

  elif [[ "$1" == '--opt3' ]]; then
    show_info

  elif [[ "$1" == '--opt4' ]]; then
    kitty --title "RaianeFlix Storage" -- bash -c "cd /home/media/RaianeFlix && ncdu ."

  elif [[ "$1" == '--opt5' ]]; then
    if ! erro_msg=$(xdg-open "/home/media/RaianeFlix" 2>&1); then
      notify-send -u critical -t 5000 "RaianeFlix" "Erro ao abrir diretório: $erro_msg" -i error
    fi
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
esac
