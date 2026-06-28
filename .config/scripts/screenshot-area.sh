#!/usr/bin/env bash
set -euo pipefail
DIR="${XDG_PICTURES_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$DIR"
FILE="$DIR/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"
grim -g "$(slurp)" "$FILE"
wl-copy < "$FILE"
notify-send "Captura de ecrã" "Área guardada em Capturas"
