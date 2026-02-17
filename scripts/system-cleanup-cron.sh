#!/bin/bash

# Script Wrapper para Cronjob - Limpeza do Sistema
# Este script é executado pelo cron sem interação do usuário

# Definir variáveis de ambiente necessárias
export PATH="/home/raianeeo/.local/bin:/usr/local/bin:/usr/bin:/bin"
export HOME="/home/raianeeo"
export DISPLAY=":0"  # Para notificações GUI
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Log file para o cron
LOG_FILE="$HOME/.local/share/system-cleanup.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Função para log
log_cron() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_cron "=== INICIANDO LIMPEZA AUTOMÁTICA VIA CRON ==="

# Executar o script principal e capturar a saída
{
    echo "Executando limpeza automática em $(date)"
    /home/raianeeo/.local/bin/system-cleanup.sh
    echo "Limpeza concluída em $(date)"
} >> "$LOG_FILE" 2>&1

# Manter apenas os últimos 30 dias de logs
find "$(dirname "$LOG_FILE")" -name "system-cleanup.log" -mtime +30 -delete 2>/dev/null

log_cron "=== LIMPEZA FINALIZADA ==="

exit 0