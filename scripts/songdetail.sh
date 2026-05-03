#!/bin/bash

MAX_LEN=80 # Comprimento máximo antes de quebrar a linha

if [[ $(playerctl -p spotify status 2>/dev/null) == "Playing" ]]; then
  status='▶ '
else
  status='󰏤 '
fi

title=$(playerctl -p spotify metadata --format "{{title}}")
artist=$(playerctl -p spotify metadata --format "{{artist}}")

wrap_text() {
  local text="$1"
  local max="$2"
  local result=""

  while [[ ${#text} -gt $max ]]; do
    result+="${text:0:$max}\n"
    text="${text:$max}"
  done
  result+="$text"

  echo -e "$result"
}

full_info="${status}${title}   ${artist}"

if [[ ${#full_info} -gt $MAX_LEN ]]; then
  wrapped_title=$(wrap_text "${status}${title}" $MAX_LEN)
  wrapped_artist=$(wrap_text "$artist" $MAX_LEN)
  echo -e "${wrapped_title}   ${artist}"
else
  echo "$full_info"
fi
