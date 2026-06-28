# Dotfiles — Niri + Noctalia Shell + Arch Linux

Configurações pessoais para meu ambiente Arch Linux com:

- **WM:** Niri (compositor Wayland)
- **Shell:** Noctalia Shell (barra, painéis, widgets)
- **Terminal:** Kitty + Fish + JetBrainsMono Nerd Font
- **Tema:** Escuro (adw-gtk3-dark, Breeze Dark)
- **SDDM:** Astronaut Theme
- **Fastfetch:** Config personalizada

## Instalação

```bash
git clone https://github.com/rael2pac/niri.git /tmp/niri
cp -r /tmp/niri/.config/* ~/.config/
```

Ou use o script completo (recomendado):

```bash
curl -sS https://raw.githubusercontent.com/rael2pac/niri/main/install-niri.sh | bash
```