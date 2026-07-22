#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# migrate-v4-to-v5.sh
# Remove Noctalia v4 (Quickshell) e instala Noctalia v5
# Preserva configs do Niri e aplica estrutura oficial v5
# ──────────────────────────────────────────────────────────

if [ -z "$BASH_VERSION" ]; then
  echo -e "\033[0;31m✘\033[0m Execute com bash: bash migrate-v4-to-v5.sh"
  exit 1
fi

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
CYAN='\033[0;36m'; MAG='\033[0;35m'; BOLD='\033[1m'; NC='\033[0m'

step()  { echo -e "\n  ${CYAN}━━━ ${MAG}★${NC} ${BOLD}$1${NC} ${CYAN}━━━${NC}"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }
ok()   { echo -e "  ${GREEN}✔${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }

# ── Verificação ──
if [ "$EUID" -eq 0 ]; then
  echo -e "\033[0;31m✘\033[0m Não execute como root."
  exit 1
fi

echo ""
echo -e "  ${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
echo -e "  ${CYAN}▓${NC}   ${BOLD}Noctalia v4 → v5 Migration${NC}    ${CYAN}▓${NC}"
echo -e "  ${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
echo ""

# ── 1. Remover pacotes v4 ──
step "🧹 Removendo Noctalia v4..."

for pkg in noctalia-shell noctalia-qs quickshell; do
  if pacman -Qi "$pkg" &>/dev/null 2>&1; then
    info "Removendo $pkg..."
    sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
    ok "$pkg removido"
  fi
done

# ── 2. Remover config v4 ──
step "🗑️  Removendo configs v4..."

if [ -d "$HOME/.config/noctalia" ]; then
  if ls "$HOME/.config/noctalia/"*.json &>/dev/null 2>&1; then
    info "Removendo ~/.config/noctalia/ (JSON v4)..."
    rm -rf "$HOME/.config/noctalia"
    ok "Config v4 removida"
  else
    info "~/.config/noctalia/ mantida (sem JSON, provável v5)"
  fi
fi

if [ -d "$HOME/.config/noctaliav5" ]; then
  rm -rf "$HOME/.config/noctaliav5"
  ok "~/.config/noctaliav5/ removida"
fi

# Remover config Quickshell legada
for dir in "$HOME/.config/quickshell" "$HOME/.local/share/quickshell"; do
  [ -d "$dir" ] && rm -rf "$dir" && ok "$dir removido"
done

# ── 3. Instalar Noctalia v5 ──
step "📦 Instalando Noctalia v5 (AUR)..."

if ! command -v yay &>/dev/null; then
  info "Instalando yay..."
  sudo pacman -Sy --needed --noconfirm git base-devel
  rm -rf /tmp/yay-bin
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  (cd /tmp/yay-bin && makepkg -si --noconfirm)
  rm -rf /tmp/yay-bin
fi

if pacman -Qi noctalia-git &>/dev/null 2>&1; then
  ok "Noctalia v5 já instalado"
else
  yay -S --needed --noconfirm noctalia-git
  ok "Noctalia v5 instalado"
fi

# ── 4. Criar config oficial v5 ──
step "📝 Criando config oficial Noctalia v5..."

mkdir -p "$HOME/.config/noctalia"

if [ ! -f "$HOME/.config/noctalia/config.toml" ]; then
  cat > "$HOME/.config/noctalia/config.toml" << 'EOF'
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
EOF
  ok "~/.config/noctalia/config.toml criado"
fi

# Garantir source rael2pac se config já existia
if ! grep -q 'rael2pac/noctalia-v5-plugins' "$HOME/.config/noctalia/config.toml" 2>/dev/null; then
  cat >> "$HOME/.config/noctalia/config.toml" << 'EOF'

    [[plugins.source]]
    kind = "git"
    location = "https://github.com/rael2pac/noctalia-v5-plugins.git"
    name = "rael2pac"
EOF
  ok "Source rael2pac adicionada"
fi

# ── 5. Aplicar configs do Niri + Noctalia do projeto ──
step "📂 Aplicando configs do projeto rael2pac/niri..."

if [ ! -d "$HOME/.config/niri" ]; then
  info "Nenhuma config do Niri encontrada. Clonando do GitHub..."
  git clone --depth=1 https://github.com/rael2pac/niri.git /tmp/niri-dotfiles
  cp -r /tmp/niri-dotfiles/.config/* "$HOME/.config/"
  # Garantir que a config do Noctalia v5 foi criada
  mkdir -p "$HOME/.config/noctalia"
  if [ -f /tmp/niri-dotfiles/.config/noctalia/config.toml ]; then
    cp /tmp/niri-dotfiles/.config/noctalia/config.toml "$HOME/.config/noctalia/config.toml"
  fi
  rm -rf /tmp/niri-dotfiles
  ok "Configs do projeto aplicadas"
else
  info "Config do Niri já existe — mantendo a atual"
  # Só garante que config.toml do Noctalia existe
  if [ ! -f "$HOME/.config/noctalia/config.toml" ]; then
    git clone --depth=1 https://github.com/rael2pac/niri.git /tmp/niri-dotfiles
    mkdir -p "$HOME/.config/noctalia"
    cp /tmp/niri-dotfiles/.config/noctalia/config.toml "$HOME/.config/noctalia/config.toml"
    rm -rf /tmp/niri-dotfiles
    ok "config.toml do Noctalia copiado do projeto"
  fi
fi

# Ajustar caminhos absolutos para o usuário atual
find "$HOME/.config" -type f \( -name "*.json" -o -name "*.conf" -o -name "bookmarks" \) \
  -exec sed -i "s|/home/rael/|$HOME/|g" {} + 2>/dev/null || true

# ── 6. Final ──
step "✅ Migração concluída!"
echo -e "  ${CYAN}→${NC} Noctalia v5 instalado e configurado"
echo -e "  ${CYAN}→${NC} Config oficial: ~/.config/noctalia/config.toml"
echo -e "  ${CYAN}→${NC} Reinicie o Niri ou execute: noctalia"
echo ""