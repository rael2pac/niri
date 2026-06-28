# Dotfiles — Niri + Noctalia Shell + Arch Linux

Configurações pessoais para meu ambiente Arch Linux com:

- **WM:** Niri (compositor Wayland)
- **Shell:** Noctalia Shell (barra, painéis, widgets)
- **Terminal:** Kitty + Fish + JetBrainsMono Nerd Font
- **Tema:** Escuro (adw-gtk3-dark, Breeze Dark)
- **SDDM:** Astronaut Theme
- **Fastfetch:** Config personalizada

## Instalação

### 1. Instalar o Arch

Use o `archinstall`. Durante a instalação:

- **Perfil**: selecione `xorg` (não precisa de DE, o script instala o Niri depois)
- **Driver**: escolha o compatível com sua placa (`NVIDIA`, `AMD`, `Intel`, `VMware`)
- **Kernels**: pode marcar `linux-zen` e `linux-lts` (opcional, o script instala os headers)

### 2. Rodar o script

Após bootar com seu usuário:

```bash
git clone https://github.com/rael2pac/niri
cd niri
bash install-niri.sh
```

Ou via curl (não precisa nem clonar):

```bash
curl -sS https://raw.githubusercontent.com/rael2pac/niri/main/install-niri.sh | bash
```

O script instala tudo automaticamente — pacotes, drivers, temas, fontes, configs — e pergunta se quer iniciar o SDDM ou reiniciar.