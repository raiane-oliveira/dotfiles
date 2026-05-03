#!/bin/bash

perc=$(cat /sys/class/power_supply/BAT0/capacity)
if [ "$perc" -gt 80 ]; then
  echo "$perc%  "
elif [ "$perc" -gt 50 ]; then
  echo "$perc%  "
elif [ "$perc" -gt 20 ]; then
  echo "$perc%  "
else echo "$perc%  "; fi
