# Dotfiles — Niri + Noctalia Shell + Arch Linux

Configurações pessoais do meu ambiente Arch Linux feitas por [Rael2pac](https://github.com/rael2pac).
Perfeito para quem quer um Arch bonito, funcional e pronto para o dia a dia sem precisar configurar nada na mão.

## 🖥️ O que vem instalado

| Categoria | Programas |
|-----------|-----------|
| **Compositor** | Niri (Wayland, scrollável por workspaces) |
| **Shell/Gerenciador** | Noctalia Shell (barra, widgets, painéis) |
| **Terminal** | Kitty + Fish + JetBrainsMono Nerd Font |
| **Tema** | Escuro (adw-gtk3-dark, Breeze Dark) |
| **Login** | SDDM + Tema Astronaut |
| **Navegador** | Firefox |
| **Arquivos** | Dolphin (KDE) |
| **Editor** | VS Code, Kate |
| **Áudio** | PipeWire + WirePlumber |
| **Bluetooth** | BlueZ + Blueman |
| **Firewall** | UFW + GUFW (funcionando com tema escuro e sem erros de display) |
| **Cache KDE** | kded6 + environment.d — "Abrir com" do Dolphin sempre funciona |
| **Ícones** | BRC-Devices, Breeze-Round-Chameleon Dark (trocável pelo nwg-look) |
| **Fontes** | JetBrains Mono, Meslo, Hack, FiraCode, Fantasque (Nerd Fonts) |

## 🚀 Para instalar

### 1. Tenha o Arch Linux instalado

Se ainda não instalou, use o `archinstall`:

```bash
archinstall
```

Durante a instalação:
- **Perfil**: selecione `xorg` (não precisa de ambiente gráfico, o script instala tudo)
- **Driver**: escolha o da sua placa (`NVIDIA`, `AMD`, `Intel`, `VMware`)
- **Rede**: pode pular, o script instala os pacotes depois

Após reiniciar, faça login com seu usuário.

### 2. Rode o script de instalação

```bash
git clone https://github.com/rael2pac/niri
cd niri
bash install-niri.sh
```

Ou diretamente (sem clonar):

```bash
curl -sS https://raw.githubusercontent.com/rael2pac/niri/main/install-niri.sh | bash
```

**O script faz tudo sozinho:**
- Instala todos os pacotes (Niri, Noctalia Shell, Dolphin, Firefox, áudio, Bluetooth, firewall, etc.)
- Configura tema escuro, ícones e fontes
- Cria o wrapper do GUFW (para abrir o firewall em modo escuro sem erros)
- Configura SDDM com tema Astronaut
- Ativa Bluetooth, áudio e serviços necessários
- No final pergunta se quer iniciar o SDDM ou reiniciar

## 🔧 Pós-instalação

### Firewall (GUFW)

Já funciona pronto. Para abrir:
- Pelo **lançador de apps** (`Mod+D` → digite "firewall")
- Pelo **terminal**: `gufw`

Vai abrir em **modo escuro** e sem erro de display.

**Importante:** Se for usar máquinas virtuais (virt-manager/libvirt) ou Android (Waydroid), o UFW bloqueia o tráfego por padrão. O script de instalação já libera automaticamente. Se instalou o UFW depois, rode:

```bash
# libvirt (VMs)
sudo ufw route allow in on virbr0
sudo ufw route allow out on virbr0
sudo ufw route allow from 192.168.122.0/24
sudo ufw route allow to 192.168.122.0/24

# Waydroid (Android)
sudo ufw allow 53
sudo ufw allow 67
sudo ufw route allow in on waydroid0
sudo ufw route allow out on waydroid0
```

> **🛡️ GUFW (Firewall)** — O GUFW abre com tema escuro e pede senha normalmente (polkit). Funciona em **máquinas físicas** com Niri + XWayland. Pode não funcionar em VMs ou ambientes sem X11. O script instala e configura tudo automaticamente.

### Tema de ícones

Se quiser mudar o tema de ícones:

```bash
nwg-look
```

Escolha o tema, clique em **Apply** — propaga na hora para todos os apps.
O daemon `xsettingsd` já está rodando no startup pra isso funcionar.

> ⚠️ **No qt6ct/qt5ct**, escolha um tema de ícone que esteja **instalado no sistema**. Temas que não existem podem causar ícones quebrados no Kate, Dolphin e outros apps Qt. Os temas disponíveis são: `Breeze_Dark_RC`, `Breeze_RC`, `BRC-Devices` e os padrões do sistema (`breeze-dark`, `breeze`, `Adwaita`).

### Dolphin — "Abrir com" sempre funcionando

No Niri (Wayland), o cache do KDE (`ksycoca6`) pode ficar desatualizado depois de instalar programas novos, fazendo o "Abrir com" do Dolphin parar de funcionar.

**Solução completa (3 camadas):**

| Camada | O que faz | Arquivo |
|--------|-----------|---------|
| **1. kded6** | Mantém o cache incremental em segundo plano | `~/.config/niri/config.kdl` (spawn-at-startup) |
| **2. environment.d** | Expõe vars Qt/KDE pro systemd/DBus desde o login | `~/.config/environment.d/*.conf` |
| **3. Hook do pacman** | Reconstrói o cache do zero após instalar/remover qualquer pacote | `/etc/pacman.d/hooks/kde-cache.hook` |

O hook roda `kbuildsycoca6 --noincremental` com as variáveis de ambiente corretas
(`XDG_RUNTIME_DIR`, `DBUS_SESSION_BUS_ADDRESS`) para **todos os usuários**
do sistema, em **qualquer** transação do pacman (`Target = *`).

### Configurar teclado

O layout padrão é `br` (ABNT2). Para trocar, edite `~/.config/niri/config.kdl` na seção `input`:

```kdl
input {
    keyboard {
        xkb {
            layout "us"   // mude para seu layout
        }
    }
}
```

Depois recarregue com `Mod+Shift+E` ou:
```bash
niri msg action quit
```

## 🗂️ Estrutura do projeto

```
niri/
├── install-niri.sh                   ← Script de instalação completo
├── .config/
│   ├── niri/config.kdl               ← Config do compositor
│   ├── noctalia/                      ← Tema e settings do Noctalia Shell
│   ├── fish/                          ← Config do Fish shell
│   ├── kitty/                         ← Config do terminal Kitty
│   ├── fastfetch/                     ← Info do sistema
│   ├── gtk-3.0/ gtk-4.0/             ← Tema escuro do GTK
│   ├── qt5ct/ qt6ct/                  ← Tema escuro do Qt
│   ├── nwg-look/                      ← Config do seletor de temas
│   ├── environment.d/                 ← Variáveis de ambiente para systemd
│   │   ├── 01-xdg-base.conf           ← Diretórios XDG
│   │   └── 10-kde-on-niri.conf        ← Qt/KDE vars (tema, prefixo, etc.)
│   └── ...
├── .local/
│   ├── bin/gufw                       ← Wrapper do firewall (pkexec + dark)
│   └── share/applications/gufw.desktop ← Atalho do firewall
├── etc/
│   └── pacman.d/hooks/kde-cache.hook  ← Hook pós-transação do pacman
└── README.md
```

## 📝 Atalhos do Niri

| Atalho | Ação |
|--------|------|
| `Mod+T` | Abrir terminal (Kitty) |
| `Mod+D` | Lançador de apps (fuzzel) |
| `Mod+E` | Abrir Dolphin |
| `Mod+Q` | Fechar janela |
| `Mod+F` | Maximizar coluna |
| `Mod+Shift+F` | Tela cheia |
| `Mod+1` a `Mod+9` | Trocar de workspace |
| `Mod+H/J/K/L` | Navegar entre janelas |
| `Mod+Shift+E` | Sair do Niri |
| `Print` | Screenshot da tela |
| `Alt+Tab` | Alternar janelas recentes |

> `Mod` = tecla Super (a do Windows/Comando)

## 💡 Dicas

- **Internet por celular (USB tethering)**: conecte o celular no USB, ative o roteamento USB — o NetworkManager gerencia automaticamente
- **Atualizar o sistema**: `sudo pacman -Syu`
- **Instalar programas do AUR**: `yay -S nome-do-pacote`