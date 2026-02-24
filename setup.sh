#!/usr/bin/env bash
# =============================================================================
# badsignal dotfiles setup
# ~/.dotfiles/setup.sh
# =============================================================================

set -euo pipefail

DOTFILES="$HOME/.dotfiles"
CONFIG="$HOME/.config"

# Colors (monochrome, naturally)
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
OK="\033[32m"
ERR="\033[31m"
WARN="\033[33m"
INFO="\033[37m"

log_info()  { echo -e "${INFO}${BOLD}  →  $*${RESET}"; }
log_ok()    { echo -e "${OK}${BOLD}  ✓  $*${RESET}"; }
log_warn()  { echo -e "${WARN}${BOLD}  ⚠  $*${RESET}"; }
log_err()   { echo -e "${ERR}${BOLD}  ✗  $*${RESET}"; }
log_title() { echo -e "\n${BOLD}$*${RESET}\n${DIM}$(printf '%.0s─' {1..50})${RESET}"; }

# =============================================================================
# Helpers
# =============================================================================

confirm() {
    read -rp "$(echo -e "${WARN}  ?  $1 [y/N] ${RESET}")" ans
    [[ "${ans,,}" == "y" ]]
}

symlink() {
    local src="$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        log_warn "Source not found, skipping: $src"
        return
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"

    # Backup existing file/dir if it's not already a symlink to our dotfiles
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
        log_warn "Backing up existing: $dst → $backup"
        mv "$dst" "$backup"
    elif [ -L "$dst" ]; then
        rm "$dst"
    fi

    ln -sf "$src" "$dst"
    log_ok "$(basename "$dst") → $src"
}

install_pkgs() {
    local missing=()
    for pkg in "$@"; do
        pacman -Qi "$pkg" &>/dev/null || missing+=("$pkg")
    done

    if [ ${#missing[@]} -eq 0 ]; then
        log_ok "All packages already installed"
        return
    fi

    log_info "Installing: ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
}

install_aur_pkgs() {
    if ! command -v paru &>/dev/null; then
        log_warn "paru not found — skipping AUR packages: $*"
        return
    fi

    local missing=()
    for pkg in "$@"; do
        paru -Qi "$pkg" &>/dev/null || missing+=("$pkg")
    done

    if [ ${#missing[@]} -eq 0 ]; then
        log_ok "All AUR packages already installed"
        return
    fi

    log_info "Installing from AUR: ${missing[*]}"
    paru -S --needed --noconfirm "${missing[@]}"
}

# =============================================================================
# Sanity check
# =============================================================================

if [ ! -d "$DOTFILES" ]; then
    log_err "Dotfiles directory not found at $DOTFILES"
    exit 1
fi

echo -e "\n${BOLD}badsignal · dotfiles setup${RESET}"
echo -e "${DIM}$(printf '%.0s═' {1..50})${RESET}\n"
echo -e "${DIM}  dotfiles : $DOTFILES${RESET}"
echo -e "${DIM}  user     : $USER${RESET}"
echo -e "${DIM}  home     : $HOME${RESET}\n"

confirm "Proceed with setup?" || { log_info "Aborted."; exit 0; }

# =============================================================================
# 1. Packages
# =============================================================================

log_title "1/5  Packages"

install_pkgs \
    sway swayidle swaylock kanshi waybar \
    alacritty rofi-wayland mako \
    zsh tmux neovim \
    ttf-jetbrains-mono-nerd \
    grim slurp wl-clipboard \
    fzf bat ripgrep fd lazygit \
    brightnessctl \
    pipewire wireplumber pavucontrol \
    network-manager-applet \
    papirus-icon-theme \
    zsh-autosuggestions zsh-syntax-highlighting

install_aur_pkgs \
    swaylock-effects \
    bibata-cursor-theme \
    orchis-theme

# =============================================================================
# 2. Symlinks
# =============================================================================

log_title "2/5  Symlinking configs"

# Sway
symlink "$DOTFILES/sway/config"                 "$CONFIG/sway/config"

# Alacritty
symlink "$DOTFILES/alacritty/alacritty.toml"    "$CONFIG/alacritty/alacritty.toml"

# Waybar
symlink "$DOTFILES/waybar/config"               "$CONFIG/waybar/config"
symlink "$DOTFILES/waybar/style.css"            "$CONFIG/waybar/style.css"

# Rofi
symlink "$DOTFILES/rofi/monochrome.rasi"        "$CONFIG/rofi/monochrome.rasi"

# Mako
symlink "$DOTFILES/mako/config"                 "$CONFIG/mako/config"

# Swayidle
symlink "$DOTFILES/swayidle/config"             "$CONFIG/swayidle/config"

# Kanshi
symlink "$DOTFILES/kanshi/config"               "$CONFIG/kanshi/config"

# tmux
symlink "$DOTFILES/tmux/tmux.conf"              "$CONFIG/tmux/tmux.conf"

# Neovim
symlink "$DOTFILES/nvim"                        "$CONFIG/nvim"

# GTK
symlink "$DOTFILES/gtk-3.0/settings.ini"        "$CONFIG/gtk-3.0/settings.ini"
symlink "$DOTFILES/gtk-4.0/settings.ini"        "$CONFIG/gtk-4.0/settings.ini"

# Cursor
symlink "$DOTFILES/icons/default/index.theme"   "$HOME/.icons/default/index.theme"

# ZSH (these live in $HOME, not $CONFIG)
symlink "$DOTFILES/zsh/.zshrc"                  "$HOME/.zshrc"
symlink "$DOTFILES/zsh/.zprofile"               "$HOME/.zprofile"

# =============================================================================
# 3. GTK / cursor via gsettings
# =============================================================================

log_title "3/5  Applying GTK & cursor settings"

if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme        "Orchis-Black-Dark"
    gsettings set org.gnome.desktop.interface icon-theme       "Papirus-Dark"
    gsettings set org.gnome.desktop.interface cursor-theme     "Bibata-Modern-Classic"
    gsettings set org.gnome.desktop.interface font-name        "JetBrainsMono Nerd Font 11"
    gsettings set org.gnome.desktop.interface color-scheme     "prefer-dark"
    log_ok "gsettings applied"
else
    log_warn "gsettings not found — GTK settings will apply on next login"
fi

# =============================================================================
# 4. ZSH as default shell
# =============================================================================

log_title "4/5  Shell"

if [ "$SHELL" != "$(which zsh)" ]; then
    log_info "Changing default shell to zsh"
    chsh -s "$(which zsh)"
    log_ok "Shell changed — takes effect on next login"
else
    log_ok "zsh is already the default shell"
fi

# =============================================================================
# 5. Screenshots directory
# =============================================================================

log_title "5/5  Directories"

mkdir -p "$HOME/Screenshots"
log_ok "~/Screenshots created"

# =============================================================================
# Done
# =============================================================================

echo -e "\n${DIM}$(printf '%.0s═' {1..50})${RESET}"
echo -e "${BOLD}  Done. Restart sway to apply all changes.${RESET}"
echo -e "${DIM}  Mod+Shift+E → log out → log back in${RESET}\n"
