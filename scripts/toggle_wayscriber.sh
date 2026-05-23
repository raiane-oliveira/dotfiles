#!/bin/bash

# Verificar se --daemon está rodando antes de iniciar o processo
if ! pgrep -x "wayscriber" >/dev/null; then
  notify-send "Wayscriber" "Iniciando o daemon do Wayscriber..."
  wayscriber --daemon &
fi

wayscriber --daemon-toggle
