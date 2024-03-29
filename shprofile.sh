#!/bin/sh
# shellcheck disable=SC2155,SC1091

# 077 would be more secure, but 022 is more useful.
umask 022

# enhanced CD preferences
export CD_SAVE_LASTPWD="1"
export CD_USE_JABBA="1"
export CD_USE_NVM="1"
export CD_DO_LS="1"

# OS variables
[ "$(uname -s)" = "Darwin" ] && export MACOS=1 && export UNIX=1
[ "$(uname -s)" = "Linux" ] && export LINUX=1 && export UNIX=1
uname -s | grep -q "_NT-" && export WINDOWS=1
grep -q "Microsoft" /proc/version 2>/dev/null && export UBUNTU_ON_WINDOWS=1

# Fix systems missing $USER
[ -z "$USER" ] && export USER="$(whoami)"

# Count CPUs for Make jobs
if [ -n "$MACOS" ]
then
  export CPUCOUNT="$(sysctl -n hw.ncpu)"
elif [ -n "$LINUX" ]
then
  export CPUCOUNT="$(getconf _NPROCESSORS_ONLN)"
else
  export CPUCOUNT="1"
fi

if [ "$CPUCOUNT" -gt 1 ]
then
  export MAKEFLAGS="-j$CPUCOUNT"
  export BUNDLE_JOBS="$CPUCOUNT"
fi

# Enable Terminal.app folder icons
[ "$TERM_PROGRAM" = "Apple_Terminal" ] && export TERMINALAPP=1
if [ -n "$TERMINALAPP" ]
then
  set_terminal_app_pwd() {
    # Tell Terminal.app about each directory change.
    printf '\e]7;%s\a' "$(echo "file://$HOST$PWD" | sed -e 's/ /%20/g')"
  }
fi

# Enable iTerm.app tab titles
[ "$TERM_PROGRAM" = "iTerm.app" ] && export ITERMAPP=1
if [ -n "$ITERMAPP" ] && echo "$TERM" | grep -q xterm
then
    set_iterm_app_pwd() {
      printf '\e]0;%s@%s:%s\a' "${USER}" "${HOST}" "$(echo "$PWD" | sed -e "s@$HOME@~@g")"
    }
    
    [ -n "$BASH_VERSION" ] && PROMPT_COMMAND='set_iterm_app_pwd'
    # shellcheck disable=SC3024,SC3030
    [ -n "$ZSH_VERSION" ] && precmd_functions+=("set_iterm_app_pwd")
fi

# shellcheck disable=SC2164
[ -s ~/.lastpwd ] && [ -n "$CD_SAVE_LASTPWD" ] && [ "$PWD" = "$HOME" ] && \
  builtin cd "$(cat ~/.lastpwd)" 2>/dev/null

[ -n "$TERMINALAPP" ] && set_terminal_app_pwd

# Load secrets
# shellcheck disable=SC1090
[ -f "$HOME/.secrets" ] && . "$HOME/.secrets"

# Some post-secret aliases
export HOMEBREW_GITHUB_API_TOKEN="$GITHUB_TOKEN"
export GITHUB_ACCESS_TOKEN="$GITUB_TOKEN"
