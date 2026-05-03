#!/bin/bash

# Verifica o estado atual de forma rápida
STATUS=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

if [ "$STATUS" = "yes" ]; then
  bluetoothctl power off >/dev/null
  notify-send -u low -i bluetooth-disabled "Bluetooth" "Desativado"
  # Saída para o Waybar (opcional se usar interval)
  echo '{"text": "", "class": "disabled", "tooltip": "Bluetooth Desligado"}'
else
  # Tenta desbloquear (caso esteja em soft-block) e ligar
  rfkill unblock bluetooth 2>/dev/null

  if bluetoothctl power on >/dev/null 2>&1; then
    notify-send -u low -i bluetooth-active "Bluetooth" "Ativado"
    echo '{"text": "", "class": "enabled", "tooltip": "Bluetooth Ligado"}'
  else
    # Se falhar, avisa o usuário
    notify-send -u critical "Bluetooth" "Erro: org.bluez.Error.Failed"
    echo '{"text": "  ", "class": "error", "tooltip": "Erro ao ligar"}'
  fi
fi
