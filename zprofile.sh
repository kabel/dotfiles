#!/bin/bash
# load shared shell configuration
# shellcheck source=shprofile.sh
source ~/.shprofile

# check if this is a login and/or interactive shell
[[ -o login ]] && export LOGIN_ZSH="1"
[[ -o interactive ]] && export INTERACTIVE_ZSH="1"

# run zshrc if this is a login, interactive shell
if [ -n "$LOGIN_ZSH" ] && [ -n "$INTERACTIVE_ZSH" ]
then
  # shellcheck source=zshrc.sh
  source ~/.zshrc
fi

# Enable history appending instead of overwriting.
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# Correct minor directory changing spelling mistakes
setopt CORRECT_ALL

#todo: zsh completion

# Colorful prompt
USER_COLOR="$(tput bold)$(tput setaf 7)"
HOST_COLOR="$(tput bold)$(tput setaf 4)"
RESET_COLOR="$(tput sgr0)"

if [ "$USER" = "root" ]
then
  USER_COLOR="$(tput bold)$(tput setaf 5)"
fi

if [ -n "${SSH_CONNECTION}" ]
then
  HOST_COLOR="$(tput bold)$(tput setaf 6)"
fi

PS1_PREFIX="${USER_COLOR}%n${RESET_COLOR}@${HOST_COLOR}%m$RESET_COLOR %1~"
PS1_SUFFIX=$'\n'"%# "
PS1="${PS1_PREFIX}${PS1_SUFFIX}"

unset USER_COLOR
unset HOST_COLOR
unset RESET_COLOR

set_git_prompt() {
  return
}
precmd_functions+=(set_git_prompt)

# iTerm2 Integration
if [ -n "$ITERMAPP" ]
then
  source "$HOME/.iterm2_shell_integration.zsh"
fi

if [ -f "$HOMEBREW_PREFIX/etc/bash_completion.d/git-prompt.sh" ]
then
  source "$HOMEBREW_PREFIX/etc/bash_completion.d/git-prompt.sh"

  set_git_prompt() {
    __git_ps1 "$PS1_PREFIX" "$PS1_SUFFIX"
  }

  # shellcheck disable=SC2034
  GIT_PS1_SHOWCOLORHINTS=true
fi
