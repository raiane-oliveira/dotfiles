#!/usr/bin/env bash

## Author  : Raiane Oliveira
## Github  : @raiane-oliveira
#
## Applets : Switch Waybar theme

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Paths
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
TEMPLATES_DIR="$HOME/.config/waybar/themes"

# Layout columns/rows
if [[ ("$theme" == *'type-1'*) || ("$theme" == *'type-3'*) || ("$theme" == *'type-5'*) ]]; then
  list_col='1'
  list_row='5'
elif [[ ("$theme" == *'type-2'*) || ("$theme" == *'type-4'*) ]]; then
  list_col='5'
  list_row='1'
fi

# Discover available themes from templates directory
_get_themes() {
  if [[ ! -d "$TEMPLATES_DIR" ]]; then
    echo ""
    return
  fi
  find "$TEMPLATES_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
}

# Apply the chosen theme
_apply_theme() {
  local chosen_theme="$1"
  local template_dir="$TEMPLATES_DIR/$chosen_theme"

  if [[ ! -d "$template_dir" ]]; then
    notify-send -u critical -t 3000 "Waybar" "Tema '$chosen_theme' não encontrado em $TEMPLATES_DIR" -i error
    return 1
  fi

  # Overwrite config.jsonc
  cat >"$WAYBAR_CONFIG" <<EOF
{
  "include": ["$template_dir/config.jsonc"]
}
EOF

  # Overwrite style.css
  cat >"$WAYBAR_STYLE" <<EOF
@import "./colors/everforest.css";
@import url("$template_dir/style.css");
EOF

  # Reload waybar
  killall -9 waybar 2>/dev/null
  waybar &
  disown

  notify-send -u low -t 2000 "Waybar" "Tema '$chosen_theme' aplicado com sucesso!" -i dialog-ok
}

# Rofi CMD
rofi_cmd() {
  rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
    -theme-str 'textbox-prompt-colon {str: "󰒓";}' \
    -dmenu \
    -p "Waybar Theme" \
    -mesg "Selecione um tema para a Waybar" \
    -markup-rows \
    -theme "${theme}"
}

# Populate rofi with available themes
run_rofi() {
  themes="$(_get_themes)"

  if [[ -z "$themes" ]]; then
    notify-send -u critical -t 3000 "Waybar" "Nenhum tema encontrado em $TEMPLATES_DIR" -i error
    exit 1
  fi

  echo "$themes" | rofi_cmd
}

# Main
chosen="$(run_rofi)"

[[ -z "$chosen" ]] && exit 0

_apply_theme "$chosen"
