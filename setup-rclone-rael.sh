#!/usr/bin/env bash
# Configura rclone + montagem automática dos drives remotos MEUS
# Uso: bash setup-rclone-rael.sh
# Script pessoal do rael2pac — contém tokens rclone

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

step()  { echo -e "\n  ${CYAN}━━━ ${BOLD}$1${NC}"; }
info()  { echo -e "  ${CYAN}→${NC} $1"; }
ok()    { echo -e "  ${GREEN}✔${NC} $1"; }
warn()  { echo "  ${YELLOW}⚠${NC} $1"; }

step "📦 Instalando rclone..."
sudo pacman -S --needed --noconfirm rclone
ok "rclone instalado"

step "🔧 Copiando configuração dos drives..."
mkdir -p "$HOME/.config/rclone"
cp "$HOME/.config/rclone/rclone.conf" "$HOME/.config/rclone/rclone.conf" 2>/dev/null || {
  warn "rclone.conf não encontrado em ~/.config/rclone/rclone.conf"
  info "Copie manualmente antes de rodar ou configure com: rclone config"
}
ok "rclone.conf copiado (tokens pessoais)"

step "📁 Criando pastas de montagem..."
mkdir -p "$HOME/Rclone/Gdrive" "$HOME/Rclone/Mega" "$HOME/Rclone/Onedrive"
ok "Pastas criadas"

if [ -f "scripts/mount_drive.sh" ]; then
  mkdir -p "$HOME/.config/scripts"
  cp scripts/*.sh "$HOME/.config/scripts/"
  chmod +x "$HOME/.config/scripts/"*.sh
  mkdir -p "$HOME/.config/systemd/user"
  cp .config/systemd/user/mount-drive.service "$HOME/.config/systemd/user/"
  systemctl --user daemon-reload
  systemctl --user enable --now mount-drive.service
  ok "Montagem automática ativada!"
else
  warn "scripts/mount_drive.sh não encontrado — pula cópia"
  info "Copie manualmente e ative:"
  info "  systemctl --user enable --now mount-drive.service"
fi

echo ""
echo -e "  ${GREEN}✔${NC} Setup rclone-rael concluído!"
echo ""
echo "  Drives montados: Gdrive, Mega, Onedrive"
echo "    systemctl --user status mount-drive.service"
