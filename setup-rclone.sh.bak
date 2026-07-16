#!/usr/bin/env bash
# Configura rclone + montagem automática dos drives remotos
# Uso: bash setup-rclone.sh
# Execute DEPOIS do install-niri.sh (ou em qualquer Arch Linux com Niri)

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

step()  { echo -e "\n  ${CYAN}━━━ ${BOLD}$1${NC}"; }
info()  { echo -e "  ${CYAN}→${NC} $1"; }
ok()    { echo -e "  ${GREEN}✔${NC} $1"; }
warn()  { echo -e "  ${YELLOW}⚠${NC} $1"; }

step "📦 Instalando rclone..."
sudo pacman -S --needed --noconfirm rclone
ok "rclone instalado"

step "🔧 Configurando rclone..."
if [ -f "$HOME/.config/rclone/rclone.conf" ]; then
  info "Arquivo rclone.conf já existe em ~/.config/rclone/"
  echo -n "  Deseja sobrescrever? [s/N] "
  read -r resp
  if [[ "$resp" =~ ^[Ss]$ ]]; then
    echo -n "  Cole o conteúdo do rclone.conf (Ctrl+D para finalizar):"
    mkdir -p "$HOME/.config/rclone"
    cat > "$HOME/.config/rclone/rclone.conf"
    ok "rclone.conf atualizado"
  fi
else
  echo ""
  warn "Você precisa configurar o rclone. Duas opções:"
  echo "    1. Já tem um rclone.conf de outro PC? Cole abaixo agora."
  echo "    2. Vai configurar manualmente depois com: rclone config"
  echo ""
  echo -n "  Cole o conteúdo do rclone.conf (ou Enter para pular):"
  IFS= read -r -t 1 || true
  if [ -n "${REPLY:-}" ]; then
    mkdir -p "$HOME/.config/rclone"
    echo "$REPLY" > "$HOME/.config/rclone/rclone.conf"
    while IFS= read -r line; do echo "$line" >> "$HOME/.config/rclone/rclone.conf"; done
    ok "rclone.conf criado"
  else
    warn "Pulando. Depois configure com: rclone config"
  fi
fi

step "📁 Criando pastas de montagem..."
mkdir -p "$HOME/Rclone/Gdrive" "$HOME/Rclone/Mega" "$HOME/Rclone/Onedrive"
ok "Pastas criadas em ~/Rclone/"

step "⚡ Ativando montagem automática..."
if systemctl --user enable --now mount-drive.service 2>/dev/null; then
  ok "mount-drive.service ativado! Drives montados automaticamente no login."
else
  warn "Serviço mount-drive.service não encontrado."
  info "Execute primeiro o install-niri.sh ou copie manualmente:"
  info "  cp .config/systemd/user/mount-drive.service ~/.config/systemd/user/"
  info "  systemctl --user daemon-reload"
  info "  systemctl --user enable --now mount-drive.service"
fi

echo ""
echo -e "  ${GREEN}✔${NC} Setup rclone concluído!"
echo ""
echo "  Comandos úteis:"
echo "    systemctl --user status mount-drive.service  # Ver status"
echo "    journalctl --user -u mount-drive.service -f  # Ver logs"
echo "    rclone config                                # Adicionar/editar drives"
echo "    nano ~/.config/scripts/mount_drive.sh        # Adicionar novo drive"
