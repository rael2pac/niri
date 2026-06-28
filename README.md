# Dotfiles — Niri + Noctalia Shell + Arch Linux

Configurações pessoais para meu ambiente Arch Linux com:

- **WM:** Niri (compositor Wayland)
- **Shell:** Noctalia Shell (barra, painéis, widgets)
- **Terminal:** Kitty + Fish + JetBrainsMono Nerd Font
- **Tema:** Escuro (adw-gtk3-dark, Breeze Dark)
- **SDDM:** Astronaut Theme
- **Fastfetch:** Config personalizada

## Instalação completa (do Arch limpo ao desktop)

### 1. Instalar o Arch

Use o `archinstall` e selecione sua config preferida. Defina os kernels como:
- `linux-zen`
- `linux-lts`

(O script já instala os headers de ambos.)

### 2. Pós-instalação — chroot

Após o archinstall, entre no chroot e prepare o sistema:

```bash
nano /etc/makepkg.conf
```

Procure a linha `#MAKEFLAGS="-j2"` e descomente alterando para o número de núcleos da sua CPU + 1. Exemplo para 4 núcleos:

```
MAKEFLAGS="-j5"
```

Salve (Ctrl+O, Enter, Ctrl+X). Depois instale o git:

```bash
pacman -S --noconfirm git
```

### 3. Sair do chroot e bootar

```bash
exit
reboot
```

### 4. Rodar o script

Após bootar com seu usuário:

```bash
git clone https://github.com/rael2pac/niri.git
cd niri
bash install-niri.sh
```

Ou direto via curl:

```bash
curl -sS https://raw.githubusercontent.com/rael2pac/niri/main/install-niri.sh | bash
```

O script instala tudo (niri, noctalia, drivers, temas, fontes, configs) e pergunta se quer iniciar o SDDM ou reiniciar.