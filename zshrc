bindkey -v

autoload -U compinit && compinit -u

# History
HISTFILE=~/.cache/zsh/histfile
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Prompt
autoload -U colors && colors

autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ":vcs_info:git:*" formats " %F{9}(%f%F{11}%b%f%F{9})%f"

setopt prompt_subst
prompt_cursor() {
    if [[ $? -eq 0 ]]; then
        echo "%F{10}>%f"
    else
        echo "%F{9}>%f"
    fi
}
PROMPT="%F{13}%~%f${vcs_info_msg_0_} %B$(prompt_cursor)%b "

# Environment
add_path() {
    PATH="$PATH"
    PATH+=":$1"
}

add_path "$HOME/.scripts"

export MANPAGER="nvim +Man!"
export EDITOR="nvim"

# Alias
alias ls="ls --color=auto"
alias grep="grep --color=auto"

bindkey -s ^f "fzftmux\n"

# Misc
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
