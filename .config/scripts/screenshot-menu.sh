#!/bin/bash
set -euo pipefail

MONITORES=$(niri msg outputs 2>/dev/null | while IFS= read -r line; do
  if [[ "$line" == Output\ * ]]; then
    nome="${line##*\(}"
    nome="${nome%)*}"
    echo "$nome"
  fi
done | sort)

ESCOLHA=$(
{
  echo "📷  Tela inteira"
  echo "📐  Área selecionada"
  echo "🪟  Janela ativa"
  echo "🖥️  Ambos monitores"
  echo "⏱️  Timer 3s"
  echo "⏱️  Timer 5s"
  echo "⏱️  Timer 10s"
  echo "✏️  Tela inteira (editar no satty)"
  echo "✏️  Área selecionada (editar no satty)"
  echo "✏️  Janela ativa (editar no satty)"
  while IFS= read -r m; do
    echo "🖥️  $m"
  done <<< "$MONITORES"
  echo "❌  Fechar"
} | wofi --dmenu --prompt "📸 Screenshot" --width 450 --height 450 --location center 2>/dev/null
) || exit 0

CAPTURAR=""
EDITAR=false

case "$ESCOLHA" in
  "📷  Tela inteira")
    CAPTURAR="grim -o \"$(niri msg -j focused-output | grep -oP '"name":\s*"\K[^"]+')\" -" ;;
  "📐  Área selecionada")
    CAPTURAR="grim -g \"\$(slurp)\" -" ;;
  "🪟  Janela ativa")
    CAPTURAR="niri msg action screenshot-window" ;;
  "🖥️  Ambos monitores")
    CAPTURAR="grim -" ;;
  "⏱️  Timer 3s") bash "$HOME/.config/scripts/screenshot-timer.sh" 3;;
  "⏱️  Timer 5s") bash "$HOME/.config/scripts/screenshot-timer.sh" 5;;
  "⏱️  Timer 10s") bash "$HOME/.config/scripts/screenshot-timer.sh" 10;;
  "✏️  Tela inteira (editar no satty)")
    CAPTURAR="grim -o \"$(niri msg -j focused-output | grep -oP '"name":\s*"\K[^"]+')\" -"; EDITAR=true ;;
  "✏️  Área selecionada (editar no satty)")
    CAPTURAR="grim -g \"\$(slurp)\" -"; EDITAR=true ;;
  "✏️  Janela ativa (editar no satty)")
    CAPTURAR="niri msg action screenshot-window"; EDITAR=true ;;
  🖥️\ *)
    NOME="${ESCOLHA#🖥️  }"
    CAPTURAR="grim -o \"$NOME\" -" ;;
  *) exit 0 ;;
esac

if [ -n "$CAPTURAR" ]; then
  if $EDITAR; then
    TMPFILE="/tmp/screenshot-edit-$$.png"
    eval "$CAPTURAR" | tee "$TMPFILE" | wl-copy
    satty -f "$TMPFILE" 2>/dev/null &
    notify-send "📸 Screenshot" "Copiado e abrindo satty para editar"
  else
    eval "$CAPTURAR" | wl-copy
    notify-send "📸 Screenshot" "Copiado para área de transferência"
  fi
fi
