#!/bin/bash
# load shared shell configuration
# shellcheck source=shprofile.sh
source ~/.shprofile

# check if this is a login and/or interactive shell
shopt -q login_shell && export LOGIN_BASH="1"
echo "$-" | grep -q "i" && export INTERACTIVE_BASH="1"

# run bashrc if this is a login, interactive shell
if [ -n "$LOGIN_BASH" ] && [ -n "$INTERACTIVE_BASH" ]
then
  # shellcheck source=bashrc.sh
  source ~/.bashrc
fi

# Set HOST for ZSH compatibility
export HOST=$HOSTNAME

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Enable history appending instead of overwriting.
shopt -s histappend

# Save multiline commands
shopt -s cmdhist

# Correct minor directory changing spelling mistakes
shopt -s cdspell

# Bash completion
[ -f /etc/profile.d/bash-completion ] && source /etc/profile.d/bash-completion
[ -f "$HOMEBREW_PREFIX/etc/bash_completion" ] && source "$HOMEBREW_PREFIX/etc/bash_completion" >/dev/null
#[ -d "$HOMEBREW_PREFIX/etc/bash_completion.d" ] && export BASH_COMPLETION_COMPAT_DIR="$HOMEBREW_PREFIX/etc/bash_completion.d"
[ -f "$HOMEBREW_PREFIX/share/bash-completion/bash_completion" ] && source "$HOMEBREW_PREFIX/share/bash-completion/bash_completion"

# has to be double-sourced for some stupid reason
[ -f "$HOMEBREW_PREFIX/etc/bash_completion.d/git-completion.bash" ] && source "$HOMEBREW_PREFIX/etc/bash_completion.d/git-completion.bash"
[ -f "$HOME/.composer/vendor/stecman/composer-bash-completion-plugin/hooks/bash-completion" ] && source "$HOME/.composer/vendor/stecman/composer-bash-completion-plugin/hooks/bash-completion" >/dev/null

# Colorful prompt
USER_COLOR="\\[$(tput bold)$(tput setaf 7)\\]"
HOST_COLOR="\\[$(tput bold)$(tput setaf 4)\\]"
RESET_COLOR="\\[$(tput sgr0)\\]"
BACK_GREY_COLOR="\\[\e[0;48;2;45;54;59m\\]"
FORE_GREY_COLOR="\\[\e[0;38;2;45;54;59m\\]"

if [ -n "$TERMINALAPP" ]
then
  BACK_GREY_COLOR="\\[$(tput setab 237)\\]"
  FORE_GREY_COLOR="\\[$(tput setaf 237)\\]"
fi

if [ "$USER" = "root" ]
then
  USER_COLOR="$(tput bold)$(tput setaf 5)"
fi

if [ -n "${SSH_CONNECTION}" ]
then
  HOST_COLOR="$(tput bold)$(tput setaf 6)"
fi

PROMPT_DIRTRIM=3
PS1_PREFIX="${BACK_GREY_COLOR} ${USER_COLOR}\\u${RESET_COLOR}${BACK_GREY_COLOR}@${HOST_COLOR}\\H${RESET_COLOR}${BACK_GREY_COLOR} ${RESET_COLOR}${FORE_GREY_COLOR}${RESET_COLOR} \\w "
PS1_SUFFIX='\n\$ '
PS1="${PS1_PREFIX}${PS1_SUFFIX}"

unset USER_COLOR
unset HOST_COLOR
unset RESET_COLOR
unset BACK_GREY_COLOR
unset FORE_GREY_COLOR

set_git_prompt() {
  return
}
precmd_functions+=(set_git_prompt)

# iTerm2 Integration
if [ $ITERMAPP ]
then
  source "$HOME/.iterm2_shell_integration.bash"
fi

if [ "$(type -t __git_ps1)" = "function" ]
then
  set_git_prompt() {
    __git_ps1 "$PS1_PREFIX" "$PS1_SUFFIX" "\\[$(tput setaf 2)$(tput smso)\\]\\[$(tput sgr0)$(tput setab 2)$(tput setaf 0)\\]  %s \\[$(tput sgr0)$(tput setaf 2)\\]\\[$(tput sgr0)\\]"
  }

  export GIT_PS1_SHOWDIRTYSTATE=true

  if [ -z "$ITERM_SHELL_INTEGRATION_INSTALLED" ]
  then
    export PROMPT_COMMAND="set_git_prompt; $PROMPT_COMMAND"
  fi
fi

if [ -z "$ITERM_SHELL_INTEGRATION_INSTALLED" ]
then
  export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
else
  __flush_history() {
    history -a
  }
  precmd_functions+=(__flush_history)
fi

# only set key bindings on interactive shell
if [ -n "$INTERACTIVE_BASH" ]
then
  # fix delete key on macOS
  [ "$MACOS" ] && bind '"\e[3~" delete-char'

  # alternate mappings for Ctrl-U/V to search the history
  bind '"^u" history-search-backward'
  bind '"^v" history-search-forward'
fi
