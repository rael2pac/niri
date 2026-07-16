#!/bin/bash
# Monta drives remotos via rclone. Adicione drives copiando um bloco de REMOTE/MOUNTPOINT.

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

FLAGS=(
    --vfs-cache-mode writes
    --allow-other
    --allow-non-empty
    --dir-cache-time 72h
    --vfs-cache-max-age 5m
    --vfs-read-chunk-size 128M
    --vfs-read-chunk-size-limit 1G
    --attr-timeout 1s
    --poll-interval 15s
    --log-level INFO
    --buffer-size 64M
)

command -v rclone &>/dev/null || { log "rclone nao instalado — saindo"; exit 0; }

# Gdrive
REMOTE="Gdrive:"
MOUNTPOINT="$HOME/Rclone/Gdrive"
mkdir -p "$MOUNTPOINT"
log "Montando Gdrive..."
rclone mount "$REMOTE" "$MOUNTPOINT" "${FLAGS[@]}" --daemon && log "Gdrive montado" || log "Gdrive FALHOU"

# Mega
REMOTE="Mega:"
MOUNTPOINT="$HOME/Rclone/Mega"
mkdir -p "$MOUNTPOINT"
log "Montando Mega..."
rclone mount "$REMOTE" "$MOUNTPOINT" "${FLAGS[@]}" --daemon && log "Mega montado" || log "Mega FALHOU"

# Onedrive
REMOTE="Onedrive:"
MOUNTPOINT="$HOME/Rclone/Onedrive"
mkdir -p "$MOUNTPOINT"
log "Montando Onedrive..."
rclone mount "$REMOTE" "$MOUNTPOINT" "${FLAGS[@]}" --daemon && log "Onedrive montado" || log "Onedrive FALHOU"

# Dropbox (exemplo — remova o comentário para ativar)
# REMOTE="Dropbox:"
# MOUNTPOINT="$HOME/Rclone/Dropbox"
# mkdir -p "$MOUNTPOINT"
# log "Montando Dropbox..."
# rclone mount "$REMOTE" "$MOUNTPOINT" "${FLAGS[@]}" --daemon && log "Dropbox montado" || log "Dropbox FALHOU"

# Copie o bloco acima (descomentado) para adicionar outro drive, alterando:
# REMOTE, MOUNTPOINT e a label do log.
