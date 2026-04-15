#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/.dotfiles"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

log() { printf "\n[+] %s\n" "$1"; }
warn() { printf "\n[!] %s\n" "$1"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    warn "Falta comando: $1"
    exit 1
  }
}

# ---- checks ----
require_cmd sudo
require_cmd git
require_cmd curl

log "Actualizando APT e instalando base"
sudo apt update
sudo apt install -y \
  zsh git curl unzip build-essential \
  fzf ripgrep bat ca-certificates

# bat alias en Ubuntu (batcat)
if command -v batcat >/dev/null 2>&1; then
  mkdir -p "${HOME}/.local/bin"
  ln -sf "$(command -v batcat)" "${HOME}/.local/bin/bat"
fi

# ---- oh-my-zsh ----
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  log "Instalando Oh My Zsh"
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log "Oh My Zsh ya instalado"
fi

# ---- plugins (idempotentes) ----
mkdir -p "${ZSH_CUSTOM_DIR}/plugins"

clone_or_update() {
  local repo="$1"
  local dest="$2"
  if [ -d "${dest}/.git" ]; then
    git -C "${dest}" pull --ff-only || true
  else
    git clone --depth=1 "${repo}" "${dest}"
  fi
}

log "Plugins zsh"
clone_or_update https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions"

clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting \
  "${ZSH_CUSTOM_DIR}/plugins/zsh-syntax-highlighting"

# ---- nvm ----
if [ ! -d "${HOME}/.nvm" ]; then
  log "Instalando nvm"
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
  log "nvm ya instalado"
fi

# cargar nvm para esta sesión
export NVM_DIR="${HOME}/.nvm"
# shellcheck disable=SC1090
[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"

if ! command -v node >/dev/null 2>&1; then
  log "Instalando Node LTS"
  nvm install --lts
  nvm alias default 'lts/*'
else
  log "Node ya instalado: $(node -v)"
fi

# ---- symlinks de dotfiles ----
log "Creando symlinks"
link_file() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    warn "Backup de $dest -> ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi
  ln -sf "$src" "$dest"
}

link_file "${DOTFILES_DIR}/.zshrc"   "${HOME}/.zshrc"
link_file "${DOTFILES_DIR}/.aliases" "${HOME}/.aliases"
link_file "${DOTFILES_DIR}/.exports" "${HOME}/.exports"
link_file "${DOTFILES_DIR}/.gitconfig" "${HOME}/.gitconfig"

# ---- shell por defecto ----
if [ "${SHELL##*/}" != "zsh" ]; then
  log "Cambiando shell por defecto a zsh"
  chsh -s "$(which zsh)" || warn "No se pudo cambiar shell automáticamente"
fi

# ---- sane defaults ----
mkdir -p "${HOME}/projects"

log "Finalizado"
echo "Abre una nueva terminal o ejecuta: exec zsh"
