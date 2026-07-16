#!/usr/bin/env bash
set -euo pipefail
DELAY=${1:-5}
MONITOROverride=${2:-}
DIR="${XDG_PICTURES_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$DIR"
FILE="$DIR/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"
if [ -n "$MONITOROverride" ]; then
  MONITOR="$MONITOROverride"
elif niri msg -j focused-output &>/dev/null; then
  MONITOR=$(niri msg -j focused-output | grep -oP '"name":\s*"\K[^"]+')
else
  MONITOR=""
fi
ID=$(notify-send -p -u low "Captura de ecrã" "A capturar o ecrã em ${DELAY} segundos...")
for ((i=DELAY-1; i>=1; i--)); do
  sleep 1
  notify-send -r "$ID" -u low "Captura de ecrã" "A capturar o ecrã em $i segundos..."
done
sleep 1
notify-send -r "$ID" -u low "Captura de ecrã" "A capturar..."
sleep 2
if [ -n "$MONITOR" ]; then
  grim -o "$MONITOR" "$FILE"
else
  grim "$FILE"
fi
wl-copy < "$FILE"
