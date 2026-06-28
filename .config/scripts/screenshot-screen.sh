#!/usr/bin/env bash
set -euo pipefail
DIR="${XDG_PICTURES_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$DIR"
FILE="$DIR/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"
if niri msg -j outputs &>/dev/null; then
  MONITOR=$(niri msg -j focused-output | grep -oP '"name":\s*"\K[^"]+')
  grim -o "$MONITOR" "$FILE"
else
  grim "$FILE"
fi
wl-copy < "$FILE"
notify-send "Captura de ecrã" "Ecrã guardado em Capturas"
