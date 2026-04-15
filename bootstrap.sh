#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/ayunierto/wsl-ubuntu-dotfiles.git"
TARGET_DIR="${HOME}/.dotfiles"

log() { printf "\n[bootstrap] %s\n" "$1"; }

# --- prerequisitos mínimos ---
if ! command -v git >/dev/null 2>&1; then
  log "Instalando git"
  sudo apt update
  sudo apt install -y git
fi

# --- clonar o actualizar ---
if [ -d "${TARGET_DIR}/.git" ]; then
  log "Actualizando repo existente"
  git -C "${TARGET_DIR}" pull --ff-only
else
  log "Clonando dotfiles"
  git clone "${REPO_URL}" "${TARGET_DIR}"
fi

# --- ejecutar install ---
log "Ejecutando install.sh"
cd "${TARGET_DIR}"
chmod +x install.sh
./install.sh

log "Listo. Abre una nueva terminal o ejecuta: exec zsh"
