#!/usr/bin/env bash

## Rofi Language Manager — via mise
## Gerencia linguagens de programação com mise use --global

dir="$HOME/.config/rofi/applets"
theme="${dir}/pkgmanager.rasi"
img="url(\"~/.config/rofi/images/e.jpg\""

# Options
yes=''
no=''

# Linguagens suportadas com ícone, nome e slug do mise
# Formato: "icone|Label exibido|slug-mise"
declare -A LANG_ICON=(
  [node]="󰎙"
  [python]="󰌠"
  [ruby]="󰴭"
  [go]="󰟓"
  [java]="󰬷"
  [rust]="󱘗"
  [bun]="󰟣"
  [deno]="󰦅"
  [elixir]="󰣐"
  [erlang]="󰣓"
  [swift]="󰛥"
  [zig]="󰑴"
)

declare -A LANG_LABEL=(
  [node]="Node.js"
  [python]="Python"
  [ruby]="Ruby"
  [go]="Go"
  [java]="Java"
  [rust]="Rust"
  [bun]="Bun"
  [deno]="Deno"
  [elixir]="Elixir"
  [erlang]="Erlang"
  [swift]="Swift"
  [zig]="Zig"
)

# Ordem de exibição no menu principal
LANG_ORDER=(node python ruby go java rust bun deno elixir erlang swift zig)

# ── Layout lateral compartilhado ────────────────────────────────────────────

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

# ── Menu de seleção de modo ──────────────────────────────────────────────────

mode_menu() {
  printf "󰏗  Instalar\n󰋚  Instaladas\n󰚰  Atualizar" | rofi \
    -dmenu \
    -theme "${theme}" \
    -theme-str 'window {location: center; anchor: center; width: 460px;}' \
    -theme-str 'inputbar { enabled: false; border-radius: 15px 15px 0px 0px;}' \
    -theme-str 'listview {columns: 3; lines: 1; spacing: 0px; padding: 12px 8px;}' \
    -theme-str 'element {border-radius: 8px; padding: 12px 6px;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'element selected.normal {background-color: @selected;}' \
    -p "󰌠 Linguagens" \
    -mesg "Gerenciar linguagens via mise" \
    -no-custom \
    -i
}

# ── Confirmação genérica ─────────────────────────────────────────────────────

_confirm() {
  local mesg="$1"

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
    -mesg "${mesg}" \
    -no-custom \
    -i
}

# ── Verifica se uma linguagem está instalada via mise ───────────────────────

_mise_is_installed() {
  local lang="$1"
  mise ls --installed "${lang}" 2>/dev/null | grep -q .
}

# ── Versão instalada globalmente ─────────────────────────────────────────────

_mise_global_version() {
  local lang="$1"
  mise ls --global --no-header "${lang}" 2>/dev/null | awk '{print $2}' | head -1
}

# ── Lista versões remotas disponíveis ────────────────────────────────────────

_mise_versions() {
  local lang="$1"
  # latest primeiro, depois versões em ordem decrescente
  {
    echo "latest"
    mise ls-remote "${lang}" 2>/dev/null | sort -rV
  } | uniq
}

# ── Monta lista de linguagens para o menu principal ──────────────────────────

_build_lang_list() {
  for lang in "${LANG_ORDER[@]}"; do
    local icon="${LANG_ICON[$lang]}"
    local label="${LANG_LABEL[$lang]}"

    if _mise_is_installed "${lang}"; then
      local ver
      ver=$(_mise_global_version "${lang}")
      [[ -n "$ver" ]] &&
        printf "%s  %s  (%s)\n" "${icon}" "${label}" "${ver}" ||
        printf "%s  %s  ✔\n" "${icon}" "${label}"
    else
      printf "%s  %s\n" "${icon}" "${label}"
    fi
  done
}

# ── Resolve slug a partir da linha selecionada ───────────────────────────────

_slug_from_label() {
  local line="$1"
  for lang in "${LANG_ORDER[@]}"; do
    local label="${LANG_LABEL[$lang]}"
    if [[ "$line" == *"${label}"* ]]; then
      echo "${lang}"
      return
    fi
  done
}

# ── Instalar / trocar versão de uma linguagem ────────────────────────────────

run_install() {
  # 1. Seleciona a linguagem
  local lang_line
  lang_line=$(_build_lang_list | _rofi_with_sidebar \
    "󰌠 Linguagem" \
    "↩ selecionar  |  Esc cancelar")

  [[ -z "$lang_line" ]] && exit 0

  local lang
  lang=$(_slug_from_label "$lang_line")
  [[ -z "$lang" ]] && exit 0

  local label="${LANG_LABEL[$lang]}"

  # 2. Seleciona a versão
  local version
  version=$(_mise_versions "${lang}" | _rofi_with_sidebar \
    "󰌠 ${label}" \
    "↩ selecionar versão  |  Esc cancelar")

  [[ -z "$version" ]] && exit 0

  # 3. Verifica se já está instalada
  local current
  current=$(_mise_global_version "${lang}")

  if [[ "$current" == "$version" ]]; then
    _confirm "\"${label} ${version}\" já é a versão global ativa. Reinstalar?" |
      grep -q "${yes}" || exit 0
  fi

  # 4. Confirma instalação
  local answer
  answer=$(_confirm "Instalar ${label} ${version} via mise?")
  [[ "$answer" != "$yes" ]] && exit 0

  # 5. Executa
  kitty --title "Instalando ${label} ${version}" -- bash -c \
    "mise use --global ${lang}@${version}; echo; echo '── Concluído. Pressione ENTER para fechar.'; read"
}

# ── Desinstalar versão instalada ─────────────────────────────────────────────

run_uninstall_version() {
  local lang="$1"
  local version="$2"
  local label="${LANG_LABEL[$lang]}"

  local answer
  answer=$(_confirm "Desinstalar ${label} ${version}?")
  [[ "$answer" != "$yes" ]] && return 1

  kitty --title "Desinstalando ${label} ${version}" -- bash -c \
    "mise uninstall ${lang}@${version}; echo; echo '── Concluído. Pressione ENTER para fechar.'; read"
}

# ── Ver info de uma versão instalada ─────────────────────────────────────────

_show_info() {
  local lang="$1"
  local version="$2"
  local label="${LANG_LABEL[$lang]}"

  local info
  info=$(mise tool "${lang}@${version}" 2>/dev/null ||
    mise where "${lang}@${version}" 2>/dev/null ||
    echo "Caminho: $(mise where ${lang} 2>/dev/null)")

  # Complementa com mise ls
  local ls_info
  ls_info=$(mise ls --no-header "${lang}" 2>/dev/null)
  info="${info}"$'\n'"${ls_info}"

  echo "${info}" | rofi \
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
    -theme-str 'inputbar { enabled: false; border-radius: 0px 15px 0px 0px;}' \
    -theme-str 'message {padding: 8px 18px;}' \
    -theme-str 'listview {columns: 1; lines: 10; padding: 10px; spacing: 4px;}' \
    -p "󰌠 ${label} ${version}" \
    -mesg "Info  |  Esc fechar" \
    -no-custom \
    -no-fixed-num-lines
}

# ── Linguagens instaladas — gerenciar ────────────────────────────────────────

run_installed() {
  # 1. Lista apenas linguagens com ao menos 1 versão instalada
  local installed_list=""
  for lang in "${LANG_ORDER[@]}"; do
    if _mise_is_installed "${lang}"; then
      local icon="${LANG_ICON[$lang]}"
      local label="${LANG_LABEL[$lang]}"
      local ver
      ver=$(_mise_global_version "${lang}")
      [[ -n "$ver" ]] &&
        installed_list+="${icon}  ${label}  (${ver})"$'\n' ||
        installed_list+="${icon}  ${label}"$'\n'
    fi
  done

  if [[ -z "$installed_list" ]]; then
    rofi \
      -e "Nenhuma linguagem instalada via mise." \
      -theme "${theme}"
    exit 0
  fi

  local lang_line
  lang_line=$(echo -n "${installed_list}" | _rofi_with_sidebar \
    "󰋚 Instaladas" \
    "↩ selecionar  |  Esc cancelar")

  [[ -z "$lang_line" ]] && exit 0

  local lang
  lang=$(_slug_from_label "$lang_line")
  [[ -z "$lang" ]] && exit 0

  local label="${LANG_LABEL[$lang]}"

  # 2. Lista versões instaladas desta linguagem
  local versions
  versions=$(mise ls --installed --no-header "${lang}" 2>/dev/null | awk '{print $2}')

  if [[ -z "$versions" ]]; then
    rofi -e "Nenhuma versão de ${label} encontrada." -theme "${theme}"
    exit 0
  fi

  local version
  version=$(echo "${versions}" | _rofi_with_sidebar \
    "󰋚 ${label}" \
    "Versões instaladas  |  ↩ selecionar  |  Esc cancelar")

  [[ -z "$version" ]] && exit 0

  # 3. Ação sobre a versão
  local action
  action=$(printf "Desinstalar\nVer info\nDefinir global" | rofi \
    -dmenu \
    -theme "${theme}" \
    -theme-str 'window {location: center; anchor: center; width: 380px;}' \
    -theme-str 'mainbox {children: ["message", "listview"]; spacing: 0px; padding: 0px;}' \
    -theme-str 'message {border-radius: 15px 15px 0px 0px; padding: 14px 18px;}' \
    -theme-str 'textbox {horizontal-align: 0.5; font: "Adwaita Sans 11";}' \
    -theme-str 'listview {columns: 3; lines: 1; spacing: 8px; padding: 12px;}' \
    -theme-str 'element {border-radius: 8px; padding: 12px 6px;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'element selected.normal {background-color: @selected;}' \
    -p "󰋚 ${label} ${version}" \
    -mesg "O que deseja fazer?" \
    -no-custom \
    -i)

  [[ -z "$action" ]] && exit 0

  case "$action" in
  "Desinstalar")
    run_uninstall_version "${lang}" "${version}"
    ;;
  "Ver info")
    _show_info "${lang}" "${version}"
    ;;
  "Definir global")
    local answer
    answer=$(_confirm "Definir ${label} ${version} como versão global?")
    [[ "$answer" != "$yes" ]] && exit 0
    kitty --title "Definindo ${label} ${version} como global" -- bash -c \
      "mise use --global ${lang}@${version}; echo; echo '── Concluído. Pressione ENTER para fechar.'; read"
    ;;
  esac
}

# ── Atualizar linguagens instaladas ──────────────────────────────────────────

run_upgrade() {
  # Monta lista de linguagens instaladas que possuem atualização
  local upgradeable=""
  for lang in "${LANG_ORDER[@]}"; do
    if _mise_is_installed "${lang}"; then
      local icon="${LANG_ICON[$lang]}"
      local label="${LANG_LABEL[$lang]}"
      local current
      current=$(_mise_global_version "${lang}")
      upgradeable+="${icon}  ${label}  (${current} → latest)"$'\n'
    fi
  done

  if [[ -z "$upgradeable" ]]; then
    rofi -e "Nenhuma linguagem instalada via mise." -theme "${theme}"
    exit 0
  fi

  # Opção extra para atualizar tudo de uma vez
  local all_option="󰚰  Atualizar tudo"
  local selection
  selection=$(printf "%s\n%s" "${all_option}" "${upgradeable}" | _rofi_with_sidebar \
    "󰚰 Atualizar" \
    "↩ selecionar  |  Esc cancelar")

  [[ -z "$selection" ]] && exit 0

  if [[ "$selection" == *"Atualizar tudo"* ]]; then
    local answer
    answer=$(_confirm "Atualizar todas as linguagens para latest?")
    [[ "$answer" != "$yes" ]] && exit 0

    kitty --title "Atualizando todas as linguagens" -- bash -c \
      "mise upgrade; echo; echo '── Concluído. Pressione ENTER para fechar.'; read"
    return
  fi

  local lang
  lang=$(_slug_from_label "$selection")
  [[ -z "$lang" ]] && exit 0

  local label="${LANG_LABEL[$lang]}"
  local answer
  answer=$(_confirm "Atualizar ${label} para a versão latest?")
  [[ "$answer" != "$yes" ]] && exit 0

  kitty --title "Atualizando ${label}" -- bash -c \
    "mise upgrade ${lang}; echo; echo '── Concluído. Pressione ENTER para fechar.'; read"
}

# ── Ponto de entrada ─────────────────────────────────────────────────────────

MODE="${1:-menu}"

if [[ "$MODE" == "menu" ]]; then
  CHOICE=$(mode_menu)
  [[ -z "$CHOICE" ]] && exit 0

  case "$CHOICE" in
  *"Instalar"*) run_install ;;
  *"Instaladas"*) run_installed ;;
  *"Atualizar"*) run_upgrade ;;
  esac
  exit 0
fi

case "$MODE" in
install) run_install ;;
installed) run_installed ;;
upgrade) run_upgrade ;;
*)
  echo "Uso: $0 [menu|install|installed|upgrade]"
  exit 1
  ;;
esac
