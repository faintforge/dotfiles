#!/usr/bin/env bash

set -e

DOTFILES="$(realpath "$(dirname "$0")")"

GREEN="\e[1;92m"
GREEN="\e[0;97m"
FAINT="\e[2m"
ENDFMT="\e[0m"

echo -e "Initializing git submodules"
git submodule update --init

function add_config {
    # Check for both existing files/dirs and symlinks.
    if [ ! -e "$3" ] && [ ! -L "$3" ]; then
        ln -sf "$2" "$3"
        echo -e "${GREEN}$1 configured!${ENDFMT}"
    else
        echo -e "${FAINT}$1 config found - skipping${ENDFMT}"
    fi
}

mkdir -p $HOME/.config

add_config alacritty "$DOTFILES/alacritty" "$HOME/.config/alacritty"
add_config neovim    "$DOTFILES/neovim"    "$HOME/.config/nvim"
add_config wofi      "$DOTFILES/wofi"      "$HOME/.config/wofi"
add_config waybar    "$DOTFILES/waybar"    "$HOME/.config/waybar"
add_config tmux      "$DOTFILES/tmux.conf" "$HOME/.tmux.conf"
add_config zsh       "$DOTFILES/zshrc"     "$HOME/.zshrc"
add_config scripts   "$DOTFILES/scripts"   "$HOME/.scripts"
add_config hypr      "$DOTFILES/hypr"      "$HOME/.config/hypr"
add_config ghostty   "$DOTFILES/ghostty"   "$HOME/.config/ghostty"

#
# TPM
#
if [ ! -e "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo -e "${GREEN}TPM installed!${ENDFMT}"
else
    echo -e "${FAINT}TPM found - skipping${ENDFMT}"
fi

#
# Alacritty local
#
if [ ! -e "$HOME/.config/alacritty/alacritty_local.toml" ]; then
    cat > "$HOME/.config/alacritty/alacritty_local.toml" << "EOF"
[font]
size = 13.0
EOF
    echo -e "${GREEN}alacritty_local.toml created!${ENDFMT}"
else
    echo -e "${FAINT}alacritty_local.toml found - skipping${ENDFMT}"
fi

#
# Ghostty local
#
if [ ! -e "$HOME/.config/ghostty/config_local.ghostty" ]; then
    cat > "$HOME/.config/ghostty/config_local.ghostty" << "EOF"
font-size = 12.0
EOF
    echo -e "${GREEN}config_local.ghostty created!${ENDFMT}"
else
    echo -e "${FAINT}config_local.ghostty found - skipping${ENDFMT}"
fi

#
# Hyprland local
#
if [ ! -e "$HOME/.config/hypr/hyprland/local.lua" ]; then
    cat > "$HOME/.config/hypr/hyprland/local.lua" << "EOF"
-- require("hyprland.desktop")
-- require("hyprland.laptop")
EOF
    echo -e "${GREEN}hyprland/local.lua created!${ENDFMT}"
else
    echo -e "${FAINT}hyprland/local.lua found - skipping...${ENDFMT}"
fi

#
# Hyprland plugins
#
if command -v hyprland &> /dev/null; then
    echo "Hyprland found - installing plugins"

    # 'install' instead of 'ln -sf' because systemd doesn't allow symfiles
    install -m 644 -D "hypr/systemd/hyprland-plugins-updater.service" "$HOME/.config/systemd/user/hyprland-plugins-updater.service"
    install -m 644 -D "hypr/systemd/hyprland-plugins-updater.timer" "$HOME/.config/systemd/user/hyprland-plugins-updater.timer"

    systemctl daemon-reload --user
    systemctl enable --user --now hyprland-plugins-updater.timer
fi

#
# Hypridle local
#
if [ ! -e "$HOME/.config/hypr/hypridle/local.conf" ]; then
    cat > "$HOME/.config/hypr/hypridle/local.conf" << "EOF"
# source = laptop.conf
# source = desktop.conf
EOF
    echo -e "${GREEN}hypridle/local.conf created!${ENDFMT}"
else
    echo -e "${FAINT}hypridle/local.conf found - skipping...${ENDFMT}"
fi

#
# Root level things
#

if [[ -e /proc/acpi/button/lid ]]; then
    sudo mkdir -p /etc/systemd/logind.conf.d/
    sudo mkdir -p /etc/systemd/sleep.conf.d/

    sudo ln -snf "$DOTFILES/systemd/logind-lid.conf" "/etc/systemd/logind.conf.d/90-lid.conf"
    sudo ln -snf "$DOTFILES/systemd/sleep-hibernate.conf" "/etc/systemd/sleep.conf.d/90-hibernate.conf"
    echo -e "${WHITE}Lid detected - power management installed!${ENDFMT}"
else
    echo -e "${FAINT}No lid detected - power management skipped...${ENDFMT}"
fi

