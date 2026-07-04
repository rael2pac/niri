#!/usr/bin/env bash

# ──────────────────────────────────────────────
# Forçar execução com bash (antes do set -euo pipefail)
# ──────────────────────────────────────────────
if [ -z "$BASH_VERSION" ]; then
  echo -e "\033[0;31m✘\033[0m Este script precisa ser executado com bash, não com sh."
  echo "  Use: bash install-niri.sh"
  exit 1
fi

set -euo pipefail

# ──────────────────────────────────────────────
# Cores e funções
# ──────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
CYAN='\033[0;36m'; MAG='\033[0;35m'; BOLD='\033[1m'; NC='\033[0m'

step()  {
  echo ""
  echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "  ${CYAN}┃${NC} ${MAG}★${NC} ${BOLD}$1${NC}"
  echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}
info()  { echo -e "  ${CYAN}→${NC} $1"; }
ok()    { echo -e "  ${GREEN}✔${NC} $1"; }
warn()  { echo -e "  ${YELLOW}⚠${NC} $1"; }
err()   { echo -e "  ${RED}✘${NC} $1"; }

run() {
  info "$1"
  shift
  "$@"
  echo -e "  ${GREEN}✔${NC} concluído"
}

quote() {
  local quotes=(
    "O terminal é o melhor amigo do admin. — ditado popular"
    "Se não quebrou, você não mexeu o suficiente. — Lei de Murphy"
    "Linux: porque um terminal é mais leve que 5 cliques."
    "Arch btw. — todo usuário Arch"
    "Wayland é o futuro. E ele chegou."
    "Niri: o compositor que você não sabia que precisava."
    "Noctalia: porque a beleza mora nos detalhes."
    "Nem só de i3 vive o homem. — Niri 2025"
    "Pacman -Syu resolve. Sempre."
    "RTFM: a documentação é sua melhor amiga."
    "Sudo faz tudo. Inclusive café. — quase."
    "Systemd: amado por uns, odiado por outros, usado por todos."
    "AUR: porque no AUR tem de tudo, até alma gêmea."
    "Yay — porque compilar na mão é coisa do passado."
    "Tema escuro é mais que preferência, é estilo de vida."
  )
  echo -e "  ${YELLOW}💬${NC} ${quotes[$RANDOM % ${#quotes[@]}]}"
}

banner() {
  echo ""
  echo -e "  ${RED}███╗   ██╗${GREEN}██╗${YELLOW}██████╗ ${BLUE}██╗"
  echo -e "  ${RED}████╗  ██║${GREEN}██║${YELLOW}██╔══██╗${BLUE}██║"
  echo -e "  ${RED}██╔██╗ ██║${GREEN}██║${YELLOW}██████╔╝${BLUE}██║"
  echo -e "  ${RED}██║╚██╗██║${GREEN}██║${YELLOW}██╔══██╗${BLUE}██║"
  echo -e "  ${RED}██║ ╚████║${GREEN}██║${YELLOW}██║  ██║${BLUE}██║"
  echo -e "  ${RED}╚═╝  ╚═══╝${GREEN}╚═╝${YELLOW}╚═╝  ╚═╝${BLUE}╚═╝"
  echo -e "${NC}"
  echo -e "  ${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "  ${CYAN}▓${NC}        ${BOLD}Niri + Noctalia-shell${NC}          ${CYAN}▓${NC}"
  echo -e "  ${CYAN}▓${NC}     ${YELLOW}Instalação Completa — Arch Linux${NC}    ${CYAN}▓${NC}"
  echo -e "  ${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "  ${MAG}✦${NC}  ${BOLD}By Rael2pac${NC}  ${MAG}✦${NC}"
  echo ""
  quote
  echo ""
}

# ──────────────────────────────────────────────
# Verificação: não rodar como root
# ──────────────────────────────────────────────
if [ "$EUID" -eq 0 ]; then
  echo -e "\033[0;31m✘\033[0m NÃO execute este script como root (sudo)."
  echo "  Execute como usuário normal. O script usará sudo automaticamente."
  exit 1
fi

# ──────────────────────────────────────────────
# 1. Boas-vindas
# ──────────────────────────────────────────────
banner

echo -e "  ${YELLOW}⚠${NC} Este script irá transformar seu Arch recém-instalado"
echo -e "     em um ambiente Niri + Noctalia Shell completo."
echo -e "  ${YELLOW}⚠${NC} Certifique-se de estar conectado à internet."
echo ""
echo -n "  ${CYAN}⌨${NC} Pressione ENTER para iniciar a instalação... "
read -r
echo ""

# ──────────────────────────────────────────────
# Verificar sudo
# ──────────────────────────────────────────────
if ! command -v sudo &>/dev/null; then
  echo -e "\033[0;31m✘\033[0m 'sudo' não está instalado."
  echo "  Entre como root e instale: pacman -S sudo"
  echo "  Depois configure: echo \"$USER ALL=(ALL) ALL\" >> /etc/sudoers"
  exit 1
fi

info "Verificando acesso sudo... (digite sua senha se solicitado)"
if ! sudo -v; then
  echo -e "\033[0;31m✘\033[0m Você não tem permissão sudo."
  echo "  Entre como root e configure: echo \"$USER ALL=(ALL) ALL\" >> /etc/sudoers"
  exit 1
fi
ok "Acesso sudo confirmado"

# ──────────────────────────────────────────────
# 2. Detectar pendrive com configs
# ──────────────────────────────────────────────
step "🔍 Procurando backup em pendrive..."

PENDRIVE=""
for mount in /run/media/"$USER"/* /mnt/* /media/*; do
  [ -d "$mount" ] && [ -f "$mount/niri.tar.gz" ] && PENDRIVE="$mount" && break
done

if [ -n "$PENDRIVE" ]; then
  info "Pendrive detectado em: $PENDRIVE"
  quote
else
  warn "Nenhum pendrive com niri.tar.gz encontrado."
  warn "Suas configs serão restauradas do git (se disponível)."
fi

# ──────────────────────────────────────────────
# 3. Otimizar compilação + ferramentas básicas
# ──────────────────────────────────────────────
step "⚙️ Otimizando sistema para compilação..."

run "Sincronizando bancos e instalando nano, git..." sudo pacman -Sy --needed --noconfirm nano git

if ! sudo pacman -Qi base-devel &>/dev/null; then
  run "Instalando base-devel..." sudo pacman -S --needed --noconfirm base-devel
fi

CORES=$(nproc)
MAKEFLAGS="-j$((CORES + 1))"
if grep -q "^#MAKEFLAGS" /etc/makepkg.conf 2>/dev/null; then
  sudo sed -i "s/^#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"$MAKEFLAGS\"/" /etc/makepkg.conf
  ok "MAKEFLAGS ajustado para $MAKEFLAGS ($CORES núcleos + 1)"
elif ! grep -q "^MAKEFLAGS" /etc/makepkg.conf 2>/dev/null; then
  echo "MAKEFLAGS=\"$MAKEFLAGS\"" | sudo tee -a /etc/makepkg.conf > /dev/null
  ok "MAKEFLAGS definido como $MAKEFLAGS"
else
  info "MAKEFLAGS já configurado"
fi

if ! command -v yay &>/dev/null; then
  info "Preparando AUR helper (yay)..."
  rm -rf /tmp/yay-bin
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  (cd /tmp/yay-bin && makepkg -si --noconfirm)
  rm -rf /tmp/yay-bin
  ok "yay instalado com sucesso"
  quote
fi

# ──────────────────────────────────────────────
# 4. Pacotes oficiais
# ──────────────────────────────────────────────
OFFICIAL_PACKAGES=(
  niri dolphin dolphin-plugins kde-cli-tools kio unrar unrar-free unzip
  pacman-contrib kate cmake cmake-extras fish bc fastfetch inxi wget
  code gnome-calculator papers loupe btop gnome-disk-utility
  gnome-text-editor ark kitty firefox vlc vlc-plugins-all mpv
  xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-wlr
  xdg-desktop-portal-gnome bash-completion vlc-plugin-ffmpeg
  archlinux-xdg-menu xdg-user-dirs xdg-user-dirs-gtk sddm
  nwg-displays polkit-gnome wiremix network-manager-applet
  alsa-utils ffmpeg ffmpegthumbs ffmpegthumbnailer
  breeze breeze5 breeze-icons breeze-gtk qt5ct
  ufw gufw ufw-extras
  satty cpio vulkan-tools imagemagick
  bluez bluez-hid2hci bluez-tools bluez-utils bluez-deprecated-tools
  blueman libldac libfdk-aac xwayland-satellite xorg-xhost
  pipewire pipewire-pulse pipewire-alsa pipewire-audio wireplumber
  grim slurp wl-clipboard fuzzel playerctl brightnessctl libnotify
  linux-lts-headers linux-zen-headers
  nwg-look xsettingsd
  noto-fonts noto-fonts-emoji ttf-dejavu
  ntfs-3g exfatprogs dosfstools btrfs-progs xfsprogs
  jfsutils f2fs-tools udftools e2fsprogs gvfs
)

step "📦 Instalando pacotes oficiais..."
info "${#OFFICIAL_PACKAGES[@]} pacotes — isso pode levar alguns minutos..."
info "Confira o progresso abaixo:"
info "ntfs-3g exfatprogs dosfstools btrfs-progs xfsprogs jfsutils f2fs-tools udftools e2fsprogs gvfs — suporte a sistemas de arquivos"
echo ""

sudo pacman -S --needed --noconfirm "${OFFICIAL_PACKAGES[@]}"
echo ""
ok "Pacotes oficiais instalados"

# Garantir que nautilus não foi puxado como dependência
if pacman -Qi nautilus &>/dev/null; then
  info "Removendo nautilus (puxado como dependência)..."
  sudo pacman -Rdd --noconfirm nautilus > /dev/null 2>&1 || true
  ok "nautilus removido"
fi
quote

# ──────────────────────────────────────────────
# 5. Pacotes AUR
# ──────────────────────────────────────────────
AUR_PACKAGES=(
  noctalia-shell noctalia-qs
  qt6ct-kde ttf-ms-fonts
  orchis-theme adw-gtk-theme
)

step "🌟 Instalando pacotes AUR..."
info "Noctalia Shell, temas e fontes Microsoft..."
info "Confira o progresso abaixo:"
echo ""

yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
echo ""
ok "Pacotes AUR instalados"
quote

# ──────────────────────────────────────────────
# 5b. Verificar instalação do Niri
# ──────────────────────────────────────────────
step "🔍 Verificando instalação do Niri..."

if command -v niri &>/dev/null; then
  ok "Niri detectado: $(niri --version 2>/dev/null || echo 'versão desconhecida')"
else
  warn "Niri não foi encontrado no PATH."
  info "Tentando reinstalar..."
  sudo pacman -S --noconfirm niri
  if command -v niri &>/dev/null; then
    ok "Niri instalado com sucesso!"
  else
    err "Niri ainda não encontrado. Instale manualmente: sudo pacman -S niri"
  fi
fi
quote

# ──────────────────────────────────────────────
# 6. Nerd Fonts
# ──────────────────────────────────────────────
NERD_FONTS=(
  ttf-jetbrains-mono-nerd
  ttf-meslo-nerd
  ttf-hack-nerd
  ttf-firacode-nerd
  ttf-fantasque-nerd
  ttf-nerd-fonts-symbols
)

step "🔤 Instalando Nerd Fonts..."
info "JetBrains Mono, Meslo, Hack, FiraCode, Fantasque..."
echo ""

sudo pacman -S --needed --noconfirm "${NERD_FONTS[@]}"
echo ""
run "Atualizando cache de fontes..." sudo fc-cache -f
ok "Nerd Fonts instaladas — seu terminal nunca mais será o mesmo"
quote

# ──────────────────────────────────────────────
# 7. SDDM + Astronaut Theme
# ──────────────────────────────────────────────
step "🚀 Configurando SDDM..."

if ! pacman -Qi sddm-astronaut-theme &>/dev/null; then
  info "Instalando tema astronauta..."
  yay -S --needed --noconfirm sddm-astronaut-theme
fi

sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<'EOF'
[Theme]
Current=sddm-astronaut-theme
EOF
ok "Tema astronauta definido como padrão"

if [ -n "$PENDRIVE" ] && [ -f "$PENDRIVE/sddm.conf.tar.gz" ]; then
  sudo tar -xzf "$PENDRIVE/sddm.conf.tar.gz" -C /etc/
  info "Configurações do SDDM restauradas do pendrive"
fi
quote

# ──────────────────────────────────────────────
# 8. Restaurar configs
# ──────────────────────────────────────────────
step "📂 Restaurando suas configurações..."

if [ -n "$PENDRIVE" ]; then
  info "Extraindo configs do pendrive..."
  for archive in niri.tar.gz noctalia.tar.gz; do
    if [ -f "$PENDRIVE/$archive" ]; then
      tar -xzf "$PENDRIVE/$archive" -C "$HOME/.config"
      ok "${archive%.tar.gz} restaurado"
    fi
  done
  for cfg in fastfetch kitty fish gtk-3.0 gtk-4.0 qt5ct qt6ct fuzzel; do
    if [ -f "$PENDRIVE/$cfg.tar.gz" ]; then
      tar -xzf "$PENDRIVE/$cfg.tar.gz" -C "$HOME/.config"
      info "$cfg restaurado"
    fi
  done
  if [ -f "$PENDRIVE/icons.tar.gz" ]; then
    mkdir -p "$HOME/.local/share/icons"
    tar -xzf "$PENDRIVE/icons.tar.gz" -C "$HOME/.local/share/icons"
    ok "Ícones restaurados do pendrive"
  fi
  quote
fi

# Fallback: clonar dotfiles do git automaticamente
if [ ! -d "$HOME/.config/niri" ]; then
  warn "Nenhuma config encontrada no pendrive. Clonando do GitHub..."
  info "Baixando dotfiles de https://github.com/rael2pac/niri.git"
  echo ""
  git clone https://github.com/rael2pac/niri.git /tmp/niri-dotfiles
  cp -r /tmp/niri-dotfiles/.config/* "$HOME/.config/"
  if [ -f /tmp/niri-dotfiles/icons.tar.gz ]; then
    mkdir -p "$HOME/.local/share/icons"
    tar -xzf /tmp/niri-dotfiles/icons.tar.gz -C "$HOME/.local/share/icons"
    ok "Ícones restaurados do GitHub!"
  fi
  rm -rf /tmp/niri-dotfiles
  ok "Configurações restauradas do GitHub!"
  quote
fi

# ──────────────────────────────────────────────
# 8b. Corrigir caminhos absolutos para o usuário atual
# ──────────────────────────────────────────────
step "🔄 Adaptando configs para seu usuário..."
info "Substituindo caminhos de /home/rael/ e ~ para o usuário atual"
find "$HOME/.config" -type f \( -name "*.json" -o -name "*.conf" -o -name "bookmarks" \) \
  -exec sed -i "s|/home/rael/|$HOME/|g" {} + 2>/dev/null || true
find "$HOME/.config" -type f -name "*.conf" \
  -exec sed -i "s|^color_scheme_path=~|color_scheme_path=$HOME|" {} + 2>/dev/null || true
ok "Caminhos ajustados para $USER"
quote

# ──────────────────────────────────────────────
# 8c. Wrapper gufw (pkexec + dark theme)
# ──────────────────────────────────────────────
step "🛡️ Configurando wrapper gufw..."

mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/gufw" << 'GUFWEOF'
#!/bin/bash
xhost +SI:localuser:root
pkexec env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" GTK_THEME="adw-gtk3-dark" /usr/bin/gufw-pkexec "$(whoami)"
GUFWEOF
chmod +x "$HOME/.local/bin/gufw"

# Garantir ~/.local/bin no PATH (se não estiver)
if ! echo "$PATH" | tr ':' '\n' | grep -q "$HOME/.local/bin"; then
  warn "~/.local/bin não está no PATH. Adicione ao ~/.bash_profile ou ~/.config/fish/config.fish"
  info "Exemplo: echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bash_profile"
fi

ok "gufw wrapper criado em ~/.local/bin/gufw"

# Desktop file override — garante que o lançador use o wrapper
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/gufw.desktop" << GUFWDESKTOP
[Desktop Entry]
Name=Firewall Configuration
Exec=$HOME/.local/bin/gufw
Icon=gufw
Terminal=false
Type=Application
Categories=GNOME;GTK;Settings;Security;
GUFWDESKTOP
ok "Desktop file criado em ~/.local/share/applications/gufw.desktop"
quote

# ──────────────────────────────────────────────
# 8d. Hook do pacman — reconstruir cache KDE automaticamente
# ──────────────────────────────────────────────
step "⚡ Configurando hook do Pacman para cache KDE..."

if [ -d "/tmp/niri-dotfiles/etc/pacman.d/hooks" ]; then
  sudo mkdir -p /etc/pacman.d/hooks
  sudo cp /tmp/niri-dotfiles/etc/pacman.d/hooks/* /etc/pacman.d/hooks/
  ok "Hook instalado — cache KDE atualizado a cada instalação/remoção de pacotes"
else
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  if [ -f "$SCRIPT_DIR/etc/pacman.d/hooks/kde-cache.hook" ]; then
    sudo mkdir -p /etc/pacman.d/hooks
    sudo cp "$SCRIPT_DIR/etc/pacman.d/hooks/kde-cache.hook" /etc/pacman.d/hooks/
    ok "Hook instalado — cache KDE atualizado a cada instalação/remoção de pacotes"
  fi
fi
quote

# ──────────────────────────────────────────────
# 8e. UFW — liberar tráfego do libvirt + Waydroid
# ──────────────────────────────────────────────
step "🔓 Configurando UFW para libvirt + Waydroid..."

if command -v ufw &>/dev/null; then
  # Libera forwarding na bridge virbr0 (NAT das VMs)
  sudo ufw route allow in on virbr0 2>/dev/null || true
  sudo ufw route allow out on virbr0 2>/dev/null || true
  sudo ufw route allow from 192.168.122.0/24 2>/dev/null || true
  sudo ufw route allow to 192.168.122.0/24 2>/dev/null || true

  # Waydroid — DNS, DHCP e forward na waydroid0
  sudo ufw allow 53 2>/dev/null || true
  sudo ufw allow 67 2>/dev/null || true
  sudo ufw route allow in on waydroid0 2>/dev/null || true
  sudo ufw route allow out on waydroid0 2>/dev/null || true

  ok "Regras UFW adicionadas — libvirt e Waydroid com internet"
else
  warn "UFW não encontrado. Se instalar depois, rode:"
  info "  sudo ufw route allow in on virbr0 && sudo ufw route allow out on virbr0"
  info "  sudo ufw allow 53 && sudo ufw allow 67"
  info "  sudo ufw route allow in on waydroid0 && sudo ufw route allow out on waydroid0"
fi
quote

# ──────────────────────────────────────────────
# 8f. Garantir polkit-gnome no config.kdl
# ──────────────────────────────────────────────
step "🔑 Garantindo polkit-gnome no config.kdl..."

CONFIG_KDL="$HOME/.config/niri/config.kdl"
POLKIT_SPAWN='spawn-at-startup "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"'

if ! grep -qF "$POLKIT_SPAWN" "$CONFIG_KDL" 2>/dev/null; then
  # Adiciona depois da linha do xsettingsd
  sed -i '/spawn-at-startup "xsettingsd"/a\'"$POLKIT_SPAWN" "$CONFIG_KDL"
  ok "polkit-gnome adicionado ao config.kdl"
else
  ok "polkit-gnome já está no config.kdl"
fi
quote

# ──────────────────────────────────────────────
# 9. Ativar serviços
# ──────────────────────────────────────────────
step "⚡ Ativando serviços do sistema..."

info "Bluetooth..."
sudo systemctl enable --now bluetooth || true
ok "Bluetooth ativado"

info "PipeWire (áudio)..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>&1 || true
ok "PipeWire ativado"

info "SDDM (login)..."
sudo systemctl enable sddm 2>&1 || true
ok "SDDM pronto para iniciar"

quote

# ──────────────────────────────────────────────
# 10. Configurar tema escuro
# ──────────────────────────────────────────────
step "🌙 Aplicando tema escuro..."

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

write_gtk_dark() {
  cat > "$1" << 'EOF'
[Settings]
gtk-theme-name=adw-gtk3-dark
gtk-icon-theme-name=BRC-Devices
gtk-font-name=Adwaita Sans 11
gtk-application-prefer-dark-theme=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
EOF
}

write_gtk_dark "$HOME/.config/gtk-3.0/settings.ini"
write_gtk_dark "$HOME/.config/gtk-4.0/settings.ini"

command -v nwg-look &>/dev/null && nwg-look -a 2>&1 || true

# Reforça dark theme (nwg-look pode sobrescrever)
write_gtk_dark "$HOME/.config/gtk-3.0/settings.ini"
write_gtk_dark "$HOME/.config/gtk-4.0/settings.ini"

# Extrair temas de ícones
install_icon_theme() {
  local name="$1" file="$2" extract_dir="$3"
  local dir="$HOME/.local/share/icons/$extract_dir"
  local src=""
  if [ -f "$(dirname "$0")/$file" ]; then
    src="$(dirname "$0")/$file"
  elif [ -n "$PENDRIVE" ] && [ -f "$PENDRIVE/$file" ]; then
    src="$PENDRIVE/$file"
  fi
  if [ -n "$src" ]; then
    mkdir -p "$HOME/.local/share/icons"
    tar -xzf "$src" -C "$HOME/.local/share/icons"
    gtk-update-icon-cache "$dir" > /dev/null 2>&1 || true
    info "$name instalado em ~/.local/share/icons/"
  else
    warn "$file não encontrado — extraia manualmente em ~/.local/share/icons/"
  fi
}
install_icon_theme "Breeze-Round-Chameleon Dark" "Breeze-Round-Chameleon-Dark.tar.gz" "Breeze-Round-Chameleon Dark Icons"
install_icon_theme "KrystalSVG-Devices" "KrystalSVG-Devices.tar.gz" "KrystalSVG-Devices"
install_icon_theme "BRC-Devices" "BRC-Devices.tar.gz" "BRC-Devices"

command -v nwg-look &>/dev/null && nwg-look -a > /dev/null 2>&1 || true
ok "Tema escuro aplicado — suave para os olhos"
quote

# ──────────────────────────────────────────────
# 11. Dolphin padrão (xdg-mime)
# ──────────────────────────────────────────────
step "🐬 Definindo Dolphin como gerenciador padrão..."
info "Associando pastas ao Dolphin..."
xdg-mime default org.kde.dolphin.desktop inode/directory
xdg-mime default org.kde.dolphin.desktop x-scheme-handler/trash
ok "Dolphin é o padrão — abrir pasta = Dolphin"
quote

# ──────────────────────────────────────────────
# 12. Ícones
# ──────────────────────────────────────────────
step "🎨 Restaurando ícones..."
ICONS_DIR="$HOME/.local/share/icons"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ ! -d "$ICONS_DIR/Papirus-Dark" ]; then
  if [ -f "$SCRIPT_DIR/icons.tar.gz" ]; then
    mkdir -p "$ICONS_DIR"
    tar -xzf "$SCRIPT_DIR/icons.tar.gz" -C "$ICONS_DIR"
    ok "Ícones restaurados"
  else
    warn "icons.tar.gz não encontrado — ícones não serão instalados"
  fi
else
  info "Ícones já existem, pulando"
fi
quote

# ──────────────────────────────────────────────
# 13. xdg-user-dirs
# ──────────────────────────────────────────────
step "📁 Configurando diretórios do usuário..."
info "🔔 Criando Diretórios como Downloads, Documentos, Imagens..."
xdg-user-dirs-update 2>&1 || true
xdg-user-dirs-gtk-update 2>&1 || true
ok "Diretórios criados"


# ──────────────────────────────────────────────
# 14. Final — escolha do usuário
# ──────────────────────────────────────────────
clear 2>/dev/null || true
echo -e "${GREEN}"
echo ' ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗      █████╗  ██████╗ █████╗  ██████╗'
echo ' ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██╔══██╗██╔════╝██╔══██╗██╔══██╗'
echo ' ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ███████║██║     ███████║██║  ██║'
echo ' ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██╔══██║██║     ██╔══██║██║  ██║'
echo ' ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗██║  ██║╚██████╗██║  ██║██████╔╝'
echo ' ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝'
echo -e "${NC}"
echo ""
echo -e "  ${GREEN}✔${NC} Sistema configurado com sucesso! By Rael2pac"
echo ""
echo -e "  ${BOLD}O que deseja fazer agora?${NC}"
echo ""
echo -e "  ${CYAN}[1]${NC} Iniciar SDDM agora (tela de login)"
echo -e "  ${CYAN}[2]${NC} Reiniciar o sistema"
echo -e "  ${CYAN}[3]${NC} Sair (voltar ao terminal)"
echo ""
echo -n "  Escolha [1/2/3]: "
read -r choice

case "$choice" in
  1)
    echo ""
    info "Iniciando SDDM..."
    sudo systemctl start sddm
    ;;
  2)
    echo ""
    info "Reiniciando em 5 segundos... Pressione Ctrl+C para cancelar"
    sleep 5
    sudo reboot
    ;;
  *)
    echo ""
    info "Voltando ao terminal. Para iniciar o SDDM manualmente:"
    echo ""
    echo "    sudo systemctl start sddm"
    echo ""
    ;;
esac
