#!/usr/bin/env bash
set -euo pipefail
SECONDS=${1:-5}
DIR="${XDG_PICTURES_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$DIR"
FILE="$DIR/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"
ID=$(notify-send -p "Captura de ecrã" "A capturar o ecrã em ${SECONDS} segundos...")
for ((i=SECONDS-1; i>=1; i--)); do
  sleep 1
  notify-send -r "$ID" "Captura de ecrã" "A capturar o ecrã em $i segundos..."
done
sleep 1
notify-send -r "$ID" "Captura de ecrã" "A capturar..."
if niri msg -j focused-output &>/dev/null; then
  MONITOR=$(niri msg -j focused-output | grep -oP '"name":\s*"\K[^"]+')
  grim -o "$MONITOR" "$FILE"
else
  grim "$FILE"
fi
wl-copy < "$FILE"
notify-send -r "$ID" "Captura de ecrã" "Ecrã guardado em Capturas"
