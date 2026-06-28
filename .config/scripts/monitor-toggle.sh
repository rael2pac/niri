#!/usr/bin/env bash
# =============================================================================
# monitor-toggle.sh — Liga/desliga monitores externos no Niri
# =============================================================================
# Detecta automaticamente saídas externas (HDMI, DP, DVI, USB-C, etc)
# ignorando a tela interna (eDP, LVDS).
#
# Uso:
#   monitor-toggle.sh on    → liga todas as externas desligadas
#   monitor-toggle.sh off   → desliga todas as externas ligadas
#   monitor-toggle.sh       → toogle (liga as desligadas, desliga as ligadas)
# =============================================================================

set -euo pipefail

ACTION="${1:-toggle}"

niri msg outputs | while IFS= read -r line; do
  # Pega o nome da saída: "Output NOME (NOME):"
  if [[ "$line" =~ ^Output\ (.+)\ \((.+)\): ]]; then
    name="${BASH_REMATCH[2]}"

    # Pula saídas internas (eDP, LVDS)
    case "$name" in
      eDP-*|LVDS-*) continue ;;
    esac

    # Lê a linha seguinte pra saber se está desligada
    IFS= read -r next
    if echo "$next" | grep -q "disabled"; then
      if [[ "$ACTION" == "on" || "$ACTION" == "toggle" ]]; then
        niri msg output "$name" on
      fi
    else
      if [[ "$ACTION" == "off" || "$ACTION" == "toggle" ]]; then
        niri msg output "$name" off
      fi
    fi
  fi
done
