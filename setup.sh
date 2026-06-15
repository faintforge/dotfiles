#!/usr/bin/env bash

set -e

DOTFILES="$(realpath "$(dirname "$0")")"

GREEN="\e[1;92m"
FAINT="\e[2m"
ENDFMT="\e[0m"

function add_config {
    # Check for both existing files/dirs and symlinks.
    if [ ! -e "$3" ] && [ ! -L "$3" ]; then
        ln -sf $2 $3
        echo -e "${GREEN}$1 configured!${ENDFMT}"
    else
        echo -e "${FAINT}$1 config found - skipping...${ENDFMT}"
    fi
}

add_config alacritty $DOTFILES/alacritty $HOME/.config/alacritty
add_config neovim $DOTFILES/neovim $HOME/.config/nvim
add_config tmux $DOTFILES/tmux.conf $HOME/.tmux.conf
add_config zsh $DOTFILES/zshrc $HOME/.zshrc
add_config scripts $DOTFILES/scripts $HOME/.scripts

#
# TPM
#
if [ ! -e "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo -e "${GREEN}TPM installed!${ENDFMT}"
else
    echo -e "${FAINT}TPM found - skipping...${ENDFMT}"
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
    echo -e "${FAINT}alacritty_local.toml found - skipping...${ENDFMT}"
fi
