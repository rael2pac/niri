#!/usr/bin/env bash
# setup-rclone.sh — Configurador genérico de rclone
# Uso: bash setup-rclone.sh
# Cria pastas de montagem, copia service do repositório e ativa.
# Antes de usar, configure o rclone:
#   1. rclone config (adicionar seus drives)
#   2. Ou cole seu rclone.conf em ~/.config/rclone/rclone.conf
#
# IMPORTANTE: Para alterar ícones ou rclone.conf depois, pare o serviço primeiro:
#   systemctl --user stop mount-drive.service
#   (edite os arquivos)
#   systemctl --user start mount-drive.service

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
step() { echo -e "  ${CYAN}━━━ ${BOLD}$1${NC}"; }
ok()   { echo -e "  ${GREEN}✔${NC} $1"; }
warn() { echo "  ${YELLOW}⚠${NC} $1"; }

step "Instalando rclone..."
sudo pacman -S --needed --noconfirm rclone
ok "rclone instalado"

step "Criando pastas de montagem..."
mkdir -p "$HOME/Rclone/Gdrive" "$HOME/Rclone/Mega" "$HOME/Rclone/Onedrive"
ok "pastas criadas em ~/Rclone/"

step "Copiando script de montagem e service..."
if [ -d "$(dirname "$0")/scripts" ] && [ -d "$(dirname "$0")/.config/systemd/user" ]; then
  mkdir -p "$HOME/.config/scripts" "$HOME/.config/systemd/user"
  cp "$(dirname "$0")/scripts/mount_drive.sh" "$HOME/.config/scripts/"
  chmod +x "$HOME/.config/scripts/mount_drive.sh"
  cp "$(dirname "$0")/.config/systemd/user/mount-drive.service" "$HOME/.config/systemd/user/"
  ok "arquivos copiados"
else
  warn "Arquivos de scripts/service nao encontrados neste diretorio."
  warn "Copie scripts/mount_drive.sh e .config/systemd/user/mount-drive.service manualmente."
fi

step "Configurando rclone..."
if [ ! -f "$HOME/.config/rclone/rclone.conf" ]; then
  echo ""
  warn "rclone.conf nao encontrado em ~/.config/rclone/"
  echo "  Escolha uma opcao:"
  echo "    1. rclone config   (configurar manualmente)"
  echo "    2. Colar rclone.conf manualmente depois"
  echo ""
  echo -n "  Deseja configurar agora com rclone config? [s/N] "
  read -r resp
  if [[ "$resp" =~ ^[Ss]$ ]]; then
    rclone config
    ok "rclone configurado"
  else
    warn "Pulando. Configure depois com: rclone config"
  fi
else
  ok "rclone.conf ja existe"
fi

step "Ativando montagem automatica..."
systemctl --user daemon-reload
if systemctl --user enable --now mount-drive.service 2>/dev/null; then
  ok "montagem ativada!"
else
  warn "Falha ao ativar — verifique se rclone.conf esta configurado"
  warn "  systemctl --user status mount-drive.service"
fi

echo ""
echo -e "  ${GREEN}Setup concluido!${NC}"
echo ""
echo "  Para ver status:  systemctl --user status mount-drive.service"
echo "  Para ver logs:    journalctl --user -u mount-drive.service -f"
echo "  Para parar:       systemctl --user stop mount-drive.service"
echo "  Para editar drives: ~/.config/rclone/rclone.conf (pare o servico antes)"
echo "  Para editar icones da sidebar: ~/.local/share/user-places.xbel"
