# Dotfiles

Configuración personal para entorno de desarrollo en WSL (Ubuntu) enfocada en:

- Simplicidad
- Reproducibilidad
- Bajo mantenimiento
- Buen rendimiento

## Stack

- Shell: zsh
- Framework: oh-my-zsh
- Plugins:
  - zsh-autosuggestions
  - zsh-syntax-highlighting
- Node: nvm
- Herramientas:
  - fzf
  - ripgrep
  - bat

---

## Instalación rápida (bootstrap)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/TU_USUARIO/dotfiles/main/bootstrap.sh)"
```

## Instalación manual
```bash
git clone https://github.com/TU_USUARIO/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```
