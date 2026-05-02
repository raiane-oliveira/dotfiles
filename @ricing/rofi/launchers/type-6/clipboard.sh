#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Launcher (Modi Drun, Run, File Browser, Window)
#
## Available Styles
#
## style-1     style-2     style-3     style-4     style-5
## style-6     style-7     style-8     style-9     style-10

dir="$HOME/.config/rofi/launchers/type-6"
theme='style-5'

## Run
# cliphist list | rofi -dmenu -theme  | cliphist decode | wl-copy

rofi -modi clipboard:"$HOME/.config/rofi/scripts/cliphist-rofi-img.sh" -show clipboard -show-icons -theme "${dir}/${theme}.rasi"
