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
  echo -e "  ${CYAN}▓${NC}        ${BOLD}Niri + Noctalia${NC}          ${CYAN}▓${NC}"
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
# 2a. Limpeza de Noctalia v4 (se existir)
# ──────────────────────────────────────────────
step "🧹 Removendo Noctalia v4 (se existir)..."

V4_PACKAGES="noctalia-shell noctalia-qs quickshell"
V4_FOUND=""

for pkg in $V4_PACKAGES; do
  if pacman -Qi "$pkg" &>/dev/null; then
    info "Removendo $pkg..."
    sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
    V4_FOUND="$V4_FOUND $pkg"
  fi
done

# Remover config v4 (~/.config/noctalia/) se contiver JSON (v4)
if [ -d "$HOME/.config/noctalia" ]; then
  if ls "$HOME/.config/noctalia/"*.json &>/dev/null 2>&1; then
    info "Config v4 detectada (JSON) em ~/.config/noctalia/ — removendo..."
    rm -rf "$HOME/.config/noctalia"
    ok "Config v4 removida"
  else
    info "~/.config/noctalia/ existe mas não tem JSON — mantendo (pode ser v5)"
  fi
fi

# Remover pasta noctaliav5 (não oficial)
if [ -d "$HOME/.config/noctaliav5" ]; then
  info "Removendo ~/.config/noctaliav5/ (não oficial)..."
  rm -rf "$HOME/.config/noctaliav5"
  ok "noctaliav5 removido"
fi

if [ -n "$V4_FOUND" ]; then
  ok "Pacotes v4 removidos:$V4_FOUND"
else
  ok "Nenhum pacote v4 encontrado"
fi
quote

# ──────────────────────────────────────────────
# 2b. Detectar pendrive com configs
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
  grim slurp wl-clipboard wofi playerctl brightnessctl libnotify
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
  noctalia-git
  qt6ct-kde ttf-ms-fonts
  orchis-theme adw-gtk-theme qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg
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
# 7. SDDM + Simple SDDM Theme 2
# ──────────────────────────────────────────────
step "🚀 Configurando SDDM..."

THEME_DIR="/usr/share/sddm/themes/simple_sddm_2"
if [ ! -d "$THEME_DIR" ]; then
  info "Instalando tema Simple SDDM 2 (QT6)..."
  sudo pacman -S --needed --noconfirm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg
  git clone --depth=1 https://github.com/JaKooLit/simple-sddm-2.git /tmp/simple-sddm-2
  sudo mkdir -p "$THEME_DIR"
  sudo cp -r /tmp/simple-sddm-2/* "$THEME_DIR"
  rm -rf /tmp/simple-sddm-2
  sudo tee -a "$THEME_DIR/theme.conf" > /dev/null <<'TRANS'
TranslatePlaceholderUsername="Usuário"
TranslatePlaceholderPassword="Senha"
TranslateLogin="Entrar"
TranslateLoginFailedWarning="Login ou senha incorretos"
TranslateCapslockWarning="Caps Lock ativado"
TranslateSuspend="Suspender"
TranslateHibernate="Hibernar"
TranslateReboot="Reiniciar"
TranslateShutdown="Desligar"
TranslateSessionSelection="Selecionar Sessão"
TranslateVirtualKeyboardButtonOn="Teclado Virtual"
TranslateVirtualKeyboardButtonOff="Fechar Teclado"
TRANS
  sudo sed -i 's/^Locale=""/Locale="pt_BR"/' "$THEME_DIR/theme.conf"
fi

sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<'EOF'
[Theme]
Current=simple_sddm_2

[General]
InputMethod=qtvirtualkeyboard
EOF
ok "Simple SDDM 2 definido como padrão com tradução em português"

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
  for archive in niri.tar.gz; do
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
# 8c. Wrapper gufw (pkexec + xhost + tema escuro)
# ──────────────────────────────────────────────
step "🛡️ Configurando wrapper gufw (tema escuro)..."

mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/gufw" << 'GUFWEOF'
#!/bin/bash
xhost +SI:localuser:root
pkexec env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" GTK_THEME="adw-gtk3-dark" /usr/bin/gufw-pkexec "$(whoami)"
GUFWEOF
chmod +x "$HOME/.local/bin/gufw"

# Desktop file override — garante tema escuro no menu de aplicativos
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
ok "gufw wrapper criado (xhost + pkexec + tema escuro)"
quote

# ──────────────────────────────────────────────
# 8d. Noctalia v5 — config.toml oficial (hand-written)
# ──────────────────────────────────────────────
step "🌙 Configurando Noctalia v5..."

NOCTALIA_CONFIG_DIR="$HOME/.config/noctalia"
NOCTALIA_CONFIG="$NOCTALIA_CONFIG_DIR/config.toml"

mkdir -p "$NOCTALIA_CONFIG_DIR"

if [ ! -f "$NOCTALIA_CONFIG" ]; then
  cat > "$NOCTALIA_CONFIG" << 'NOCTALIA_EOF'
[plugins]

    [[plugins.source]]
    kind = "git"
    location = "https://github.com/noctalia-dev/official-plugins"
    name = "official"

    [[plugins.source]]
    kind = "git"
    location = "https://github.com/noctalia-dev/community-plugins"
    name = "community"

    [[plugins.source]]
    kind = "git"
    location = "https://github.com/rael2pac/noctalia-v5-plugins.git"
    name = "rael2pac"

[system.monitor]
cpu_poll_seconds = 2.0
gpu_poll_seconds = 5.0
NOCTALIA_EOF
  ok "Noctalia v5 config.toml criado com plugins rael2pac"
else
  # Garantir que source rael2pac existe no config.toml
  if ! grep -q 'rael2pac/noctalia-v5-plugins' "$NOCTALIA_CONFIG"; then
    cat >> "$NOCTALIA_CONFIG" << 'NOCTALIA_SRC'

    [[plugins.source]]
    kind = "git"
    location = "https://github.com/rael2pac/noctalia-v5-plugins.git"
    name = "rael2pac"
NOCTALIA_SRC
    ok "Source rael2pac adicionada ao config.toml"
  fi
  # Garantir que [system.monitor] com gpu_poll_seconds existe
  if ! grep -q 'gpu_poll_seconds' "$NOCTALIA_CONFIG"; then
    if grep -q '^\[system\.monitor\]' "$NOCTALIA_CONFIG"; then
      sed -i '/^\[system\.monitor\]/a gpu_poll_seconds = 5.0' "$NOCTALIA_CONFIG"
    else
      printf '\n[system.monitor]\ncpu_poll_seconds = 2.0\ngpu_poll_seconds = 5.0\n' >> "$NOCTALIA_CONFIG"
    fi
    ok "gpu_poll_seconds adicionado ao system.monitor"
  fi
fi

# Fallback: se settings.toml (GUI) já existe, garante source rael2pac lá também
NOCTALIA_SETTINGS="$HOME/.local/state/noctalia/settings.toml"
if [ -f "$NOCTALIA_SETTINGS" ] && ! grep -q 'rael2pac/noctalia-v5-plugins' "$NOCTALIA_SETTINGS"; then
  cat >> "$NOCTALIA_SETTINGS" << 'NOCTALIA_SET'

    [[plugins.source]]
    kind = "git"
    location = "https://github.com/rael2pac/noctalia-v5-plugins.git"
    name = "rael2pac"
NOCTALIA_SET
  ok "Source rael2pac adicionada ao settings.toml (GUI)"
fi
quote

# ──────────────────────────────────────────────
# 8d. Variáveis de ambiente para systemd (environment.d)
# ──────────────────────────────────────────────
step "⚡ Configurando variáveis de ambiente para systemd/DBus..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.config/environment.d"

if [ -f "$SCRIPT_DIR/.config/environment.d/01-xdg-base.conf" ]; then
  cp "$SCRIPT_DIR/.config/environment.d/01-xdg-base.conf" "$HOME/.config/environment.d/"
  # Ajusta $HOME para o usuário real
  sed -i "s|\$HOME|$HOME|g" "$HOME/.config/environment.d/01-xdg-base.conf"
  ok "01-xdg-base.conf criado — diretórios XDG"
fi

if [ -f "$SCRIPT_DIR/.config/environment.d/10-kde-on-niri.conf" ]; then
  cp "$SCRIPT_DIR/.config/environment.d/10-kde-on-niri.conf" "$HOME/.config/environment.d/"
  ok "10-kde-on-niri.conf criado — variáveis Qt/KDE para systemd"
fi

info "environment.d é lido pelo systemd --user no login. Essas variáveis"
info "ficam disponíveis para portais, DBus activation e qualquer processo"
info "iniciado pelo systemd."
quote

# ──────────────────────────────────────────────
# 8e. Scripts de sistema (wofi menus, screenshots, etc.)
# ──────────────────────────────────────────────
step "💾 Copiando scripts de sistema..."

mkdir -p "$HOME/.config/scripts"
for scr in "$SCRIPT_DIR"/.config/scripts/*.sh; do
  cp "$scr" "$HOME/.config/scripts/"
  chmod +x "$HOME/.config/scripts/$(basename "$scr")"
done
ok "scripts copiados e com permissão de execução"

if [ -d "$SCRIPT_DIR/.config/wofi" ]; then
  mkdir -p "$HOME/.config/wofi"
  cp "$SCRIPT_DIR/.config/wofi/style.css" "$HOME/.config/wofi/"
  ok "wofi style copiado"
fi
quote

# ──────────────────────────────────────────────
# 8f. Hook do pacman — reconstruir cache KDE automaticamente
# ──────────────────────────────────────────────
step "⚡ Instalando hook do Pacman para cache KDE..."

if [ -f "$SCRIPT_DIR/etc/pacman.d/hooks/kde-cache.hook" ]; then
  sudo mkdir -p /etc/pacman.d/hooks
  sudo cp "$SCRIPT_DIR/etc/pacman.d/hooks/kde-cache.hook" /etc/pacman.d/hooks/
  ok "Hook instalado — kbuildsycoca6 roda após toda transação do pacman"
  info "Funciona para TODOS os usuários do sistema (usa loginctl + sudo -u)"
  info "com as variáveis XDG_RUNTIME_DIR e DBUS_SESSION_BUS_ADDRESS corretas."
fi
quote

# ──────────────────────────────────────────────
# 8f. UFW — liberar tráfego do libvirt + Waydroid
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
