#!/usr/bin/env bash

## Rofi Package Manager
## Inspirado no omarchy-pkg-install / omarchy-pkg-aur-install
## Usa o tema rofi customizado do usuário

dir="$HOME/.config/rofi/applets"
theme="${dir}/pkgmanager.rasi"
img="url(\"~/.config/rofi/images/e.jpg\""

# Options
yes=''
no=''

# ── Menu de seleção de modo ─────────────────────────────────────────────────
# Imagem no TOPO: imagebox ocupa a linha de cima (width), botões abaixo

mode_menu() {
  printf "󰏗  Pacman\n󰣇 AUR / yay\n󰋚  Instalados" | rofi \
    -dmenu \
    -theme "${theme}" \
    -theme-str 'window {location: center; anchor: center; width: 400px;}' \
    -theme-str 'inputbar { enabled: false; border-radius: 15px 15px 0px 0px;}' \
    -theme-str 'listview {columns: 3; lines: 1; spacing: 0px; padding: 12px 8px;}' \
    -theme-str 'element {border-radius: 8px; padding: 12px 6px;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'element selected.normal {background-color: @selected;}' \
    -p "󰊠 Pacotes" \
    -mesg "Selecionar uma opção" \
    -no-custom \
    -i
}

# ── Confirmação antes de instalar ───────────────────────────────────────────

confirm_install() {
  local pkg="$1"
  local label="$2"

  printf "$yes\n$no" | rofi \
    -dmenu \
    -theme "${theme}" \
    -theme-str 'window {location: center; anchor: center; width: 380px;}' \
    -theme-str 'mainbox {children: ["message", "listview"]; spacing: 0px; padding: 0px;}' \
    -theme-str 'message {border-radius: 15px 15px 0px 0px; padding: 14px 18px;}' \
    -theme-str 'textbox {horizontal-align: 0.5; font: "Adwaita Sans 11";}' \
    -theme-str 'listview {columns: 2; lines: 1; spacing: 8px; padding: 12px;}' \
    -theme-str 'element {border-radius: 8px; padding: 12px 6px 22px 6px;}' \
    -theme-str 'element-text {vertical-align: 0.5; horizontal-align: 0.5; font: "feather bold 32";}' \
    -theme-str 'element selected.normal {background-color: @selected;}' \
    -p "Confirmar" \
    -mesg "Instalar \"${pkg}\" via ${label}?" \
    -no-custom \
    -i
}

# ── Layout lateral compartilhado (imagem à esquerda, conteúdo à direita) ───
# Usado pelos modos install, aur e installed.
# $1 = prompt  $2 = mesg  $3 = lista (via pipe — chamar com process substitution)

_rofi_with_sidebar() {
  local prompt="$1"
  local mesg="$2"

  rofi \
    -dmenu \
    -theme "${theme}" \
    -theme-str 'window {width: 1000px;}' \
    -theme-str "mainbox {
      orientation: horizontal;
      spacing: 0px; padding: 0px;
      children: [\"imagebox\", \"contentbox\"];
    }" \
    -theme-str "imagebox {
      padding: 0px;
      background-color: transparent;
      background-image: ${img}, height);
      min-width: 260px;
      border-radius: 15px 0px 0px 15px;
      orientation: vertical;
      children: [];
    }" \
    -theme-str "contentbox {
      orientation: vertical;
      spacing: 0px; padding: 0px;
      children: [\"inputbar\", \"message\", \"listview\"];
      background-color: transparent;
    }" \
    -theme-str 'inputbar {border-radius: 0px 15px 0px 0px;}' \
    -theme-str 'message {padding: 8px 18px;}' \
    -theme-str 'listview {columns: 1; lines: 10; padding: 10px; spacing: 4px;}' \
    -p "${prompt}" \
    -mesg "${mesg}" \
    -i \
    -no-custom
}

# ── Funções de cada modo ────────────────────────────────────────────────────

run_uninstall() {
  local pkg="$1"
  local title="${2:-"Desinstalando pacote"}"
  local cmd="${3:-"sudo pacman -Rns"}"

  local answer
  answer=$(printf "$yes\n$no" | rofi \
    -dmenu \
    -theme "${theme}" \
    -theme-str 'window {location: center; anchor: center; width: 380px;}' \
    -theme-str 'mainbox {children: ["message", "listview"]; spacing: 0px; padding: 0px;}' \
    -theme-str 'message {border-radius: 15px 15px 0px 0px; padding: 14px 18px;}' \
    -theme-str 'textbox {horizontal-align: 0.5; font: "Adwaita Sans 11";}' \
    -theme-str 'listview {columns: 2; lines: 1; spacing: 8px; padding: 12px;}' \
    -theme-str 'element {border-radius: 8px; padding: 12px 6px 22px 6px;}' \
    -theme-str 'element-text {vertical-align: 0.5; horizontal-align: 0.5; font: "feather bold 32";}' \
    -theme-str 'element selected.normal {background-color: @selected;}' \
    -p "Pacote instalado" \
    -mesg "\"${pkg}\" já está instalado. Desinstalar?" \
    -no-custom \
    -i)

  [[ "$answer" != "$yes" ]] && return 1

  kitty --title "${title}" -- bash -c \
    "${cmd} ${pkg}; echo; echo '── Concluído. Pressione ENTER para fechar.'; read"
}

run_install() {
  local pkg
  pkg=$(pacman -Slq 2>/dev/null | _rofi_with_sidebar \
    "󰏗 Pacman" \
    "↩ selecionar  |  Esc cancelar")

  [[ -z "$pkg" ]] && exit 0

  if pacman -Qi "${pkg}" &>/dev/null; then
    run_uninstall "${pkg}" "Desinstalando pacote" "sudo pacman -Rns" || exit 0
    return
  fi

  local answer
  answer=$(confirm_install "$pkg" "pacman")
  [[ "$answer" != "$yes" ]] && exit 0

  kitty --title "Instalando pacote" -- bash -c \
    "sudo pacman -S --needed ${pkg}; echo; echo '── Concluído. Pressione ENTER para fechar.'; read"
}

run_aur() {
  local pkg
  pkg=$(yay -Slqa 2>/dev/null | _rofi_with_sidebar \
    " AUR" \
    "↩ selecionar  |  Esc cancelar")

  [[ -z "$pkg" ]] && exit 0

  if pacman -Qi "${pkg}" &>/dev/null; then
    run_uninstall "${pkg}" "Desinstalando pacote (AUR)" "yay -Rns" || exit 0
    return
  fi

  local answer
  answer=$(confirm_install "$pkg" "yay (AUR)")
  [[ "$answer" != "$yes" ]] && exit 0

  kitty --title "Instalando do AUR" -- bash -c \
    "yay -S --needed ${pkg}; echo; echo '── Concluído. Pressione ENTER para fechar.'; read"
}

run_installed() {
  local pkg
  pkg=$(yay -Qqe 2>/dev/null | _rofi_with_sidebar \
    "󰋚 Instalados" \
    "↩ selecionar  |  Esc cancelar")

  [[ -z "$pkg" ]] && exit 0

  local action
  action=$(printf "Desinstalar\nVer info" | rofi \
    -dmenu \
    -theme "${theme}" \
    -theme-str 'window {location: center; anchor: center; width: 380px;}' \
    -theme-str 'mainbox {children: ["message", "listview"]; spacing: 0px; padding: 0px;}' \
    -theme-str 'message {border-radius: 15px 15px 0px 0px; padding: 14px 18px;}' \
    -theme-str 'textbox {horizontal-align: 0.5; font: "Adwaita Sans 11";}' \
    -theme-str 'listview {columns: 2; lines: 1; spacing: 8px; padding: 12px;}' \
    -theme-str 'element {border-radius: 8px; padding: 12px 6px;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'element selected.normal {background-color: @selected;}' \
    -p "󰋚 ${pkg}" \
    -mesg "O que deseja fazer com \"${pkg}\"?" \
    -no-custom \
    -i)

  [[ -z "$action" ]] && exit 0

  case "$action" in
  "Ver info")
    local info
    info=$(yay -Qi "${pkg}" 2>/dev/null || pacman -Qi "${pkg}" 2>/dev/null)
    echo "${info}" | rofi \
      -dmenu \
      -p "󰋚 ${pkg}" \
      -mesg "Info do pacote  |  Esc fechar" \
      -theme-str 'inputbar { enabled: false; }' \
      -theme-str 'window {width: 1000px;}' \
      -theme-str "mainbox {
        orientation: horizontal;
        spacing: 0px; padding: 0px;
        children: [\"imagebox\", \"contentbox\"];
      }" \
      -theme-str "imagebox {
        padding: 0px;
        background-color: transparent;
        background-image: ${img}, height);
        min-width: 260px;
        border-radius: 15px 0px 0px 15px;
        orientation: vertical;
        children: [];
      }" \
      -theme-str "contentbox {
        orientation: vertical;
        spacing: 0px; padding: 0px;
        children: [\"inputbar\", \"message\", \"listview\"];
        background-color: transparent;
      }" \
      -theme-str 'message {padding: 8px 18px;}' \
      -theme-str 'listview {columns: 1; lines: 10; padding: 10px; spacing: 4px;}' \
      -theme "${theme}" \
      -no-custom \
      -no-fixed-num-lines
    ;;
  "Desinstalar")
    if pacman -Qi "${pkg}" &>/dev/null; then
      run_uninstall "${pkg}" "Desinstalando pacote" "sudo pacman -Rns" || exit 0
    else
      run_uninstall "${pkg}" "Desinstalando pacote" "yay -Rns" || exit 0
    fi
    ;;
  esac
}

# ── Ponto de entrada ────────────────────────────────────────────────────────

MODE="${1:-menu}"

if [[ "$MODE" == "menu" ]]; then
  CHOICE=$(mode_menu)
  [[ -z "$CHOICE" ]] && exit 0

  case "$CHOICE" in
  *"Pacman"*) run_install ;;
  *"AUR"*) run_aur ;;
  *"Instalados"*) run_installed ;;
  esac
  exit 0
fi

case "$MODE" in
install) run_install ;;
aur) run_aur ;;
installed) run_installed ;;
*)
  echo "Uso: $0 [menu|install|aur|installed]"
  exit 1
  ;;
esac
