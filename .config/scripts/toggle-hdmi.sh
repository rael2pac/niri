#!/usr/bin/env bash
# Usage: toggle-hdmi.sh [output-name]
# If no output name is given, show a fuzzel menu with all outputs
set -euo pipefail

# extract output ID from line like: Output "Name" (HDMI-A-1)
extract_name() {
  local line="$1"
  line="${line##*\(}"
  echo "${line%\)*}"
}

if [ $# -ge 1 ]; then
  name="$1"
  if niri msg outputs | grep -A1 "($name)" | grep -q "Current mode"; then
    niri msg output "$name" off
  else
    niri msg output "$name" on
  fi
  exit 0
fi

entries=$(
  niri msg outputs | while IFS= read -r line; do
    case "$line" in
      Output*)
        if [ -n "$n" ]; then
          echo "$n|$s"
        fi
        n=$(extract_name "$line")
        s="off"
        ;;
      *Current*)
        s="on"
        ;;
    esac
  done
  if [ -n "${n:-}" ]; then
    echo "$n|$s"
  fi
)

if [ -z "$entries" ]; then
  notify-send "Monitores" "Nenhum monitor detectado"
  exit 1
fi

list=$(echo "$entries" | while IFS='|' read -r name state; do
  if [ "$state" = "on" ]; then
    echo "Desligar $name"
  else
    echo "Ligar $name"
  fi
done)

selected=$(echo "$list" | fuzzel --dmenu --lines=5 --width=30 --prompt="Monitores: " 2>/dev/null) || exit 1

case "$selected" in
  "Desligar "*) niri msg output "${selected#Desligar }" off ;;
  "Ligar "*)    niri msg output "${selected#Ligar }" on ;;
esac