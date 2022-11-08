#!/bin/bash
# check if this is a login shell
[[ -o login ]] && export LOGIN_ZSH="1"

# run zprofile if this is not a login shell
# shellcheck source=zprofile.sh
[ -z "$LOGIN_ZSH" ] && source ~/.zprofile

# load shared shell configuration
# shellcheck source=shrc.sh
source ~/.shrc

# History
export HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

