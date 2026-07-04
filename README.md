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

### Tema de ícones

Se quiser mudar o tema de ícones:

```bash
nwg-look
```

Escolha o tema, clique em **Apply** — propaga na hora para todos os apps.
O daemon `xsettingsd` já está rodando no startup pra isso funcionar.

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
│   └── ...
├── .local/
│   ├── bin/gufw                       ← Wrapper do firewall (pkexec + dark)
│   └── share/applications/gufw.desktop ← Atalho do firewall
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