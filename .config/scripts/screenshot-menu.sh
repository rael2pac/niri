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
  echo "🖥️  Monitor específico"
  while IFS= read -r m; do
    echo "⏱️  Timer 5s ($m)"
    echo "⏱️  Timer 10s ($m)"
  done <<< "$MONITORES"
  echo "✏️  Tela inteira (satty)"
  echo "✏️  Área selecionada (satty)"
  echo "✏️  Janela ativa (satty)"
  echo "❌  Fechar"
} | wofi --dmenu --prompt "📸 Screenshot" --width 450 --height 500 --location center 2>/dev/null
) || exit 0

CAPTURAR=""
EDITAR=false

if [[ "$ESCOLHA" == *"Tela inteira"* && "$ESCOLHA" != *"satty"* ]]; then
  CAPTURAR="grim -o \"$(niri msg -j focused-output | grep -oP '"name":\s*"\K[^"]+')\" -"
elif [[ "$ESCOLHA" == *"Área selecionada"* && "$ESCOLHA" != *"satty"* ]]; then
  CAPTURAR="grim -g \"\$(slurp)\" -"
elif [[ "$ESCOLHA" == *"Janela ativa"* && "$ESCOLHA" != *"satty"* ]]; then
  CAPTURAR="niri msg action screenshot-window"
elif [[ "$ESCOLHA" == *"Ambos monitores"* ]]; then
  CAPTURAR="grim -"
elif [[ "$ESCOLHA" == *"Monitor específico"* ]]; then
  NOME=$(echo "$MONITORES" | wofi --dmenu --prompt "Escolher monitor" --width 300 --height 200 --location center 2>/dev/null) || exit 0
  CAPTURAR="grim -o \"$NOME\" -"
elif [[ "$ESCOLHA" == *"Timer 5s"* ]]; then
  MONITOR=$(echo "$ESCOLHA" | grep -oP '\(\K[^)]+')
  bash "$HOME/.config/scripts/screenshot-timer.sh" 5 "$MONITOR"
  exit 0
elif [[ "$ESCOLHA" == *"Timer 10s"* ]]; then
  MONITOR=$(echo "$ESCOLHA" | grep -oP '\(\K[^)]+')
  bash "$HOME/.config/scripts/screenshot-timer.sh" 10 "$MONITOR"
  exit 0
elif [[ "$ESCOLHA" == *"Tela inteira (satty)"* ]]; then
  CAPTURAR="grim -o \"$(niri msg -j focused-output | grep -oP '"name":\s*"\K[^"]+')\" -"; EDITAR=true
elif [[ "$ESCOLHA" == *"Área selecionada (satty)"* ]]; then
  CAPTURAR="grim -g \"\$(slurp)\" -"; EDITAR=true
elif [[ "$ESCOLHA" == *"Janela ativa (satty)"* ]]; then
  CAPTURAR="niri msg action screenshot-window"; EDITAR=true
elif [[ "$ESCOLHA" == *"Fechar"* ]]; then
  exit 0
else
  exit 0
fi

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
