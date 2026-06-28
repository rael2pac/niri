#!/usr/bin/env bash
set -euo pipefail
DIR="${XDG_PICTURES_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$DIR"
FILE="$DIR/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"
ID=$(notify-send -p "Captura de ecrã" "A capturar o ecrã em 5 segundos...")
for i in 4 3 2 1; do
  sleep 1
  notify-send -r "$ID" "Captura de ecrã" "A capturar o ecrã em $i segundos..."
done
sleep 1
notify-send -r "$ID" "Captura de ecrã" "A capturar..."
if niri msg -j outputs &>/dev/null; then
  MONITOR=$(niri msg -j outputs | grep -oP '"name":\s*"[^"]*"' | grep -oP '"[^"]*"$' | tr -d '"' | head -1)
  grim -o "$MONITOR" "$FILE"
else
  grim "$FILE"
fi
wl-copy < "$FILE"
notify-send -r "$ID" "Captura de ecrã" "Ecrã guardado em Capturas"
