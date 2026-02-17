#!/bin/bash

# Script de Limpeza Automática do Sistema
# Autor: Sistema automatizado
# Data: $(date '+%Y-%m-%d')
# Descrição: Limpa caches, logs, Docker, snaps e outros arquivos temporários

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Função para erro
error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

# Função para sucesso
success() {
    echo -e "${GREEN}[SUCESSO]${NC} $1"
}

# Função para aviso
warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

# Função para enviar notificação
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    
    # Tenta diferentes formas de notificação
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u "$urgency" "$title" "$message"
    elif command -v zenity >/dev/null 2>&1; then
        zenity --info --text="$title: $message" --no-wrap
    else
        echo "NOTIFICAÇÃO: $title - $message"
    fi
}

# Função para obter espaço usado em /
get_disk_usage() {
    df / | awk 'NR==2 {print $5}' | sed 's/%//'
}

# Função para obter espaço livre em /
get_disk_free() {
    df -h / | awk 'NR==2 {print $4}'
}

# Início do script
main() {
    log "🧹 Iniciando limpeza automática do sistema..."
    
    # Captura estado inicial
    local initial_usage=$(get_disk_usage)
    local initial_free=$(get_disk_free)
    
    send_notification "🧹 Limpeza do Sistema" "Iniciando limpeza automática. Uso atual: ${initial_usage}% (${initial_free} livres)" "low"
    
    log "Estado inicial: ${initial_usage}% usado, ${initial_free} livres"
    
    # Array para armazenar resultados
    declare -a cleanup_results=()
    
    # 1. Limpeza do cache do usuário
    log "🗑️ Limpando cache do usuário..."
    local user_cache_size_before=""
    if [ -d "$HOME/.cache" ]; then
        user_cache_size_before=$(du -sh "$HOME/.cache" 2>/dev/null | cut -f1)
        
        # Limpar caches específicos (mantendo configurações importantes)
        rm -rf "$HOME/.cache/yay/" 2>/dev/null
        rm -rf "$HOME/.cache/google-chrome/" 2>/dev/null
        rm -rf "$HOME/.cache/zen/" 2>/dev/null
        rm -rf "$HOME/.cache/ms-playwright/" 2>/dev/null
        rm -rf "$HOME/.cache/nvim/" 2>/dev/null
        rm -rf "$HOME/.cache/JetBrains/" 2>/dev/null
        rm -rf "$HOME/.cache/typescript/" 2>/dev/null
        rm -rf "$HOME/.cache/pip/" 2>/dev/null
        rm -rf "$HOME/.cache/thumbnails/" 2>/dev/null
        
        # PNPM store prune (se disponível)
        if command -v pnpm >/dev/null 2>&1; then
            pnpm store prune >/dev/null 2>&1
        fi
        
        local user_cache_size_after=$(du -sh "$HOME/.cache" 2>/dev/null | cut -f1)
        cleanup_results+=("Cache do usuário: ${user_cache_size_before} → ${user_cache_size_after}")
        success "Cache do usuário limpo"
    fi
    
    # 2. Limpeza do cache do pacman
    log "📦 Limpando cache do pacman..."
    local pacman_cache_before=$(sudo du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1)
    echo -e "Y\nY" | sudo pacman -Scc >/dev/null 2>&1
    local pacman_cache_after=$(sudo du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1)
    cleanup_results+=("Cache do pacman: ${pacman_cache_before} → ${pacman_cache_after}")
    success "Cache do pacman limpo"
    
    # 3. Limpeza dos journals do systemd
    log "📋 Limpando journals do systemd..."
    local journal_size_before=$(sudo du -sh /var/log/journal/ 2>/dev/null | cut -f1)
    sudo journalctl --vacuum-time=7d >/dev/null 2>&1
    local journal_size_after=$(sudo du -sh /var/log/journal/ 2>/dev/null | cut -f1)
    cleanup_results+=("Journals: ${journal_size_before} → ${journal_size_after}")
    success "Journals limpos"
    
    # 4. Limpeza do Docker (se instalado)
    if command -v docker >/dev/null 2>&1; then
        log "🐳 Limpando Docker..."
        local docker_size_before=$(sudo du -sh /var/lib/docker/ 2>/dev/null | cut -f1)
        docker system prune -af --volumes >/dev/null 2>&1
        local docker_size_after=$(sudo du -sh /var/lib/docker/ 2>/dev/null | cut -f1)
        cleanup_results+=("Docker: ${docker_size_before} → ${docker_size_after}")
        success "Docker limpo"
    fi
    
    # 5. Limpeza de snaps antigos
    if command -v snap >/dev/null 2>&1; then
        log "📱 Limpando snaps antigos..."
        local snap_size_before=$(sudo du -sh /var/lib/snapd/ 2>/dev/null | cut -f1)
        
        # Remove revisões desabilitadas
        snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
            sudo snap remove "$snapname" --revision="$revision" >/dev/null 2>&1
        done
        
        local snap_size_after=$(sudo du -sh /var/lib/snapd/ 2>/dev/null | cut -f1)
        cleanup_results+=("Snaps: ${snap_size_before} → ${snap_size_after}")
        success "Snaps antigos removidos"
    fi
    
    # 6. Limpeza do flatpak
    if command -v flatpak >/dev/null 2>&1; then
        log "📋 Limpando flatpak..."
        flatpak uninstall --unused -y >/dev/null 2>&1
        success "Flatpak limpo"
    fi
    
    # 7. Limpeza de arquivos temporários
    log "🗂️ Limpando arquivos temporários..."
    local tmp_size_before=$(sudo du -sh /tmp/ /var/tmp/ 2>/dev/null | awk '{sum+=$1} END {print sum"M"}' | sed 's/MM/M/')
    sudo rm -rf /tmp/* /var/tmp/* 2>/dev/null
    cleanup_results+=("Arquivos temporários: ${tmp_size_before} limpos")
    success "Arquivos temporários limpos"
    
    # 8. Limpeza da lixeira
    log "🗑️ Limpando lixeira..."
    if [ -d "$HOME/.local/share/Trash/" ]; then
        local trash_size=$(du -sh "$HOME/.local/share/Trash/" 2>/dev/null | cut -f1)
        rm -rf "$HOME/.local/share/Trash/"* 2>/dev/null
        cleanup_results+=("Lixeira: ${trash_size} limpa")
        success "Lixeira limpa"
    fi
    
    # Estado final
    local final_usage=$(get_disk_usage)
    local final_free=$(get_disk_free)
    local space_freed=$((initial_usage - final_usage))
    
    log "Estado final: ${final_usage}% usado, ${final_free} livres"
    success "Limpeza concluída! Liberados ${space_freed}% de espaço em disco"
    
    # Gerar relatório
    local report="🧹 RELATÓRIO DE LIMPEZA 🧹\n\n"
    report+="📊 RESUMO:\n"
    report+="• Estado inicial: ${initial_usage}% usado (${initial_free} livres)\n"
    report+="• Estado final: ${final_usage}% usado (${final_free} livres)\n"
    report+="• Espaço liberado: ${space_freed}% do disco\n\n"
    
    report+="📋 DETALHES:\n"
    for result in "${cleanup_results[@]}"; do
        report+="• ${result}\n"
    done
    
    report+="\n✅ Limpeza concluída com sucesso!"
    
    # Notificação final
    send_notification "✅ Limpeza Concluída" "Liberados ${space_freed}% de espaço. Uso atual: ${final_usage}%" "low"
    
    # Log final
    echo -e "\n${GREEN}================================${NC}"
    echo -e "${GREEN}    LIMPEZA CONCLUÍDA COM SUCESSO${NC}"
    echo -e "${GREEN}================================${NC}"
    echo -e "$report"
    
    return 0
}

# Verificação de privilégios
if [[ $EUID -eq 0 ]]; then
    error "Este script não deve ser executado como root"
    exit 1
fi

# Executar função principal
main "$@"