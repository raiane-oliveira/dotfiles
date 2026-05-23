#!/usr/bin/env bash

## Author  : Raiane Oliveira
## Github  : @raiane-oliveira
#
## Applets : Clipboard history (clipse + rofi)
##
## Dependências: clipse, wl-clipboard, rofi, jq, python3, notify-send

# ── Paths ────────────────────────────────────────────────────────────────────
CLIPSE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/clipse"
HISTORY_FILE="$CLIPSE_DIR/clipboard_history.json"

# ── Import Current Theme ─────────────────────────────────────────────────────
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# ── Verifica dependências ────────────────────────────────────────────────────
check_deps() {
  for cmd in clipse wl-copy rofi jq python3; do
    command -v "$cmd" &>/dev/null || {
      notify-send "clipse-rofi" "Dependência ausente: $cmd"
      exit 1
    }
  done
  [ -f "$HISTORY_FILE" ] || {
    notify-send "clipse-rofi" "Histórico não encontrado: $HISTORY_FILE"
    exit 1
  }
}

# ── Número de itens no histórico ─────────────────────────────────────────────
history_length() {
  local filter="${1:-false}"
  if [ "$filter" = "true" ]; then
    jq '[.clipboardHistory[] | select(.pinned == true)] | length' "$HISTORY_FILE"
  else
    jq '.clipboardHistory | length' "$HISTORY_FILE"
  fi
}

# ── Lê um campo de um item pelo índice ───────────────────────────────────────
# Evita join() para não misturar null bytes com conteúdo do value
get_field() {
  local idx="$1" field="$2" pinned_only="$3"
  if [ "$pinned_only" = "true" ]; then
    jq -r --argjson i "$idx" --arg f "$field" \
      '[.clipboardHistory[] | select(.pinned == true)] | .[$i] | .[$f] // ""' \
      "$HISTORY_FILE"
  else
    jq -r --argjson i "$idx" --arg f "$field" \
      '.clipboardHistory[$i][$f] // ""' \
      "$HISTORY_FILE"
  fi
}

# ── Constrói entradas para o rofi ────────────────────────────────────────────
build_rofi_input() {
  local pinned_only="${1:-false}"
  local count
  count=$(history_length "$pinned_only")

  for ((i = 0; i < count; i++)); do
    local filepath pinned value recorded tipo prefix label display

    filepath=$(get_field "$i" "filePath" "$pinned_only")
    pinned=$(get_field "$i" "pinned" "$pinned_only")
    recorded=$(get_field "$i" "recorded" "$pinned_only")

    prefix=""
    [ "$pinned" = "true" ] && prefix="󰐃 "

    if [ "$filepath" != "" ] && [ "$filepath" != "null" ] && [ -f "$filepath" ]; then
      # Imagem: mostra nome do arquivo, passa o path como ícone para preview
      label="${prefix}󰋩  $(basename "$filepath")  •  ${recorded:0:19}"
      printf '%s\0icon\x1f%s\n' "$label" "$filepath"
    else
      # Texto: lê o value e trunca para exibição
      value=$(get_field "$i" "value" "$pinned_only")
      display=$(printf '%s' "$value" | head -c 120 | tr '\n\t' '  ')
      label="${prefix}${display}"
      printf '%s\n' "$label"
    fi
  done
}

# ── Abre o rofi e retorna índice + tipo da seleção ───────────────────────────
# Usa rofi -format i para retornar o índice, evitando comparação de strings
open_rofi() {
  local prompt="${1:-󰅍}"
  local pinned_only="${2:-false}"

  build_rofi_input "$pinned_only" | rofi \
    -dmenu \
    -format i \
    -theme "$theme" \
    -show-icons \
    -p "$prompt" \
    -theme-str 'configuration {
  kb-remove-char-back: "BackSpace";
  kb-row-up: "Up,Control+k,Shift+Tab,Shift+ISO_Left_Tab";
  kb-row-down: "Down,Control+j";
  kb-move-char-back: "Left,Control+h";
  kb-move-char-forward: "Right,Control+l";
}' \
    -theme-str 'window { width: 900px; height: 560px; border-radius: 15px; }' \
    -theme-str 'mainbox { orientation: horizontal; children: [ "left-pane", "right-box" ]; spacing: 20px; }' \
    -theme-str 'left-pane { width: 460px; expand: false; children: [ "icon-current-entry" ]; background-color: transparent; }' \
    -theme-str 'icon-current-entry { size: 460px; horizontal-align: 0.5; vertical-align: 0.25; background-color: transparent; }' \
    -theme-str 'right-box { orientation: vertical; children: [ "inputbar", "listview" ]; expand: true; }' \
    -theme-str 'inputbar { children: [ "prompt", "entry" ]; spacing: 10px; padding: 15px 10px; background-color: transparent; }' \
    -theme-str 'entry { placeholder: "Pesquisar..."; border-radius: 3px; cursor: text; text-color: @foreground; background-color: @background-alt; padding: 10px 14px; }' \
    -theme-str 'listview { columns: 1; lines: 10; expand: true; padding: 10px; }' \
    -theme-str 'element { orientation: horizontal; padding: 4px 8px; spacing: 10px; }' \
    -theme-str 'element-icon { size: 48px; background-color: transparent; border: 0px; }' \
    -theme-str 'textbox-prompt-colon { str: ":"; }' \
    -theme-str 'prompt { background-color: @urgent; border-radius: 3px; padding: 10px 14px; }'
}

# ── Copia para o clipboard ───────────────────────────────────────────────────
copy_item() {
  local idx="$1" pinned_only="$2"

  local filepath
  filepath=$(get_field "$idx" "filePath" "$pinned_only")

  if [ "$filepath" != "" ] && [ "$filepath" != "null" ] && [ -f "$filepath" ]; then
    local mime
    mime=$(python3 -c "import mimetypes; print(mimetypes.guess_type('$filepath')[0] or 'image/png')")
    wl-copy --type "$mime" <"$filepath" &&
      notify-send "Copiado!" "Imagem copiada para a área de transferência"
  else
    local value
    value=$(get_field "$idx" "value" "$pinned_only")
    printf '%s' "$value" | wl-copy &&
      notify-send "Copiado!" "$(printf '%s' "$value" | head -c 60)"
  fi
}

# ── Ação: selecionar do histórico completo ───────────────────────────────────
action_sel() {
  check_deps
  local idx
  idx=$(open_rofi "󰅍" "false")
  [ -z "$idx" ] && exit 0
  copy_item "$idx" "false"
}

# ── Ação: selecionar apenas pinados ─────────────────────────────────────────
action_pins() {
  check_deps
  local idx
  idx=$(open_rofi "󰐃  Pinados" "true")
  [ -z "$idx" ] && exit 0
  copy_item "$idx" "true"
}

# ── Entrypoint ───────────────────────────────────────────────────────────────
case "$1" in
sel) action_sel ;;
pins) action_pins ;;
*)
  printf "clipse-rofi | Gerenciador de área de transferência\n\n"
  printf "  sel   - Abre o histórico completo no rofi\n"
  printf "  pins  - Abre apenas itens pinados no rofi\n\n"
  printf "Histórico: %s\n" "$HISTORY_FILE"
  printf "\nDica: use 'clipse -listen' para monitorar o clipboard em background.\n"
  printf "      use 'clipse' para gerenciar pins e deletar itens pelo TUI.\n"
  exit 0
  ;;
esac
