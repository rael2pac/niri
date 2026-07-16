#!/bin/bash
set -euo pipefail

LISTA=""
while IFS= read -r line; do
  if [[ "$line" == Output\ * ]]; then
    nome="${line##*\(}"
    nome="${nome%)*}"
    IFS= read -r next
    if echo "$next" | grep -q "Current mode"; then
      LISTA+="🖥️  $nome  (ligado)"$'\n'
    else
      LISTA+="🖥️  $nome  (desligado)"$'\n'
    fi
  fi
done < <(niri msg outputs 2>/dev/null)

LISTA=$(echo "$LISTA" | sort)

[ -z "$LISTA" ] && notify-send "Monitores" "Nenhum monitor" && exit 1

ESCOLHA=$(echo "$LISTA" | wofi --dmenu --prompt "🖥️ Monitores" --width 400 --height 250 --location center 2>/dev/null) || exit 0
[ -z "$ESCOLHA" ] && exit 0

NOME="${ESCOLHA#🖥️  }"
NOME="${NOME%%  (*}"

if echo "$ESCOLHA" | grep -q "(ligado)"; then
  niri msg output "$NOME" off && notify-send "🖥️ Monitor" "$NOME desligado"
else
  niri msg output "$NOME" on  && notify-send "🖥️ Monitor" "$NOME ligado"
fi
