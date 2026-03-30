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
setopt prompt_subst

autoload -U colors && colors

autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ":vcs_info:git:*" formats " %F{9}(%f%F{11}%b%f%F{9})%f"

compact_prompt() {
    echo "%F{13}%~%f${vcs_info_msg_0_} %B$(prompt_cursor)%b "
}
compact_rprompt() {}

prompt_cursor() {
    if [[ $? -eq 0 ]]; then
        echo "%F{10}>%f"
    else
        echo "%F{9}>%f"
    fi
}

expanded_prompt() {
    echo "
%F{13}%~%f${vcs_info_msg_0_}
%B$(prompt_cursor)%b "
}
expanded_rprompt() {}

PROMPT='$(expanded_prompt)'
RPROMPT='$(expanded_rprompt)'

# https://github.com/romkatv/powerlevel10k/issues/888#issuecomment-657969840
zle-line-init() {
  emulate -L zsh

  [[ $CONTEXT == start ]] || return 0

  while true; do
    zle .recursive-edit
    local -i ret=$?
    [[ $ret == 0 && $KEYS == $'\4' ]] || break
    [[ -o ignore_eof ]] || exit 0
  done

  local saved_prompt=$PROMPT
  local saved_rprompt=$RPROMPT
  PROMPT='$(compact_prompt)'
  RPROMPT='$(compact_rprompt)'
  zle .reset-prompt
  PROMPT=$saved_prompt
  RPROMPT=$saved_rprompt

  if (( ret )); then
    zle .send-break
  else
    zle .accept-line
  fi
  return ret
}

zle -N zle-line-init

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
alias config="lazygit -p ~/.dotfiles"
alias oo="cd ~/personal"
alias on="nvim -c ObsidianNew"
alias ont="nvim -c ObsidianNewFromTemplate"

nvim_random_listen() {
    local random_number="$(od -An -N2 -i /dev/random | tr -d ' ')"
    nvim --listen "/tmp/nvim-server-$random_number" "$@"
}
alias nvim="nvim_random_listen"

bindkey -s ^f "fzftmux\n"

# Misc
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
