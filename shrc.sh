#!/bin/sh
# shellcheck disable=SC2155

# Colourful manpages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Set to avoid `env` output from changing console colour
export LESS_TERMEND=$'\E[0m'

# Print field by number
field() {
  ruby -ane "puts \$F[$1]"
}

# Setup paths
remove_from_path() {
  [ -d "$1" ] || return
  # Doesn't work for first item in the PATH but I don't care.
  export PATH=${PATH//:$1/}
}

add_to_path_start() {
  [ -d "$1" ] || return
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

add_to_path_end() {
  [ -d "$1" ] || return
  remove_from_path "$1"
  export PATH="$PATH:$1"
}

force_add_to_path_start() {
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

quiet_which() {
  which "$1" &>/dev/null
}

add_to_path_end "$HOME/bin"
add_to_path_end "$HOME/.composer/vendor/bin"
add_to_path_start "/usr/local/bin"
add_to_path_start "/usr/local/sbin"

# Aliases
alias mkdir="mkdir -vp"
alias df="df -H"
alias rm="rm -iv"
alias mv="mv -iv"
alias cp="cp -irv"
alias du="du -sh"
alias make="nice make"
alias less="less --ignore-case --raw-control-chars"
alias rsync="rsync --partial --progress --human-readable --compress"
alias rg="rg --colors 'match:style:nobold' --colors 'path:style:nobold'"
alias gist="gist --open --copy"
alias sha256="shasum -a 256"

# Platform-specific stuff
if quiet_which brew
then
  export HOMEBREW_PREFIX="$(brew --prefix)"
  export HOMEBREW_REPOSITORY="$(brew --repo)"
  export HOMEBREW_AUTO_UPDATE_SECS=3600
  export HOMEBREW_BINTRAY_USER="$(git config bintray.username)"
  export HOMEBREW_DEVELOPER=1
  export HOMEBREW_PRY=1

  alias hbc='cd $HOMEBREW_REPOSITORY/Library/Taps/homebrew/homebrew-core'

  # Output whether the dependencies for a Homebrew package are bottled.
  brew_bottled_deps() {
    for DEP in "$@"; do
      echo "$DEP deps:"
      brew deps "$DEP" | xargs brew info | grep stable
      [ "$#" -ne 1 ] && echo
    done
  }

  # Output the most popular unbottled Homebrew packages
  brew_popular_unbottled() {
    brew deps --all |
      awk '{ gsub(":? ", "\n") } 1' |
      sort |
      uniq -c |
      sort |
      tail -n 500 |
      awk '{print $2}' |
      xargs brew info |
      grep stable |
      grep -v bottled
  }
fi

if [ "$MACOS" ]
then
  export GREP_OPTIONS="--color=auto"
  export CLICOLOR="1"

  if quiet_which diff-highlight
  then
    # shellcheck disable=SC2016
    export GIT_PAGER='diff-highlight | less -+$LESS -RX'
  else
    # shellcheck disable=SC2016
    export GIT_PAGER='less -+$LESS -RX'
  fi

  #export JAVA_HOME=$(/usr/libexec/java_home)

  if quiet_which sdkmanager
  then
    export ANDROID_HOME=/usr/local/share/android-sdk
  fi

  if quiet_which exa
  then
    alias ll="exa -Fgl"
    alias l.="exa -Fgd .*"
    alias ll.="exa -Fgdl .*"
    alias ls="exa -Fg"
  else
    alias ll="ls -FGl"
    alias l.="ls -FGd .*"
    alias ll.="ls -FGld .*"
    alias ls="ls -FG"
  fi

#  add_to_path_end /Applications/Xcode.app/Contents/Developer/usr/bin
#  add_to_path_end /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
  add_to_path_end "$HOMEBREW_PREFIX/opt/git/share/git-core/contrib/diff-highlight"

  alias ql="qlmanage -p 1>/dev/null"
  alias locate="mdfind -name"
  alias cpwd="pwd | tr -d '\n' | pbcopy"
  alias finder-hide="setfile -a V"

  # Old default Curl is broken for Git on Leopard.
  [ "$OSTYPE" = "darwin9.0" ] && export GIT_SSL_NO_VERIFY=1
elif [ "$LINUX" ]
then
  quiet_which keychain && eval "$(keychain -q --eval --agents ssh id_rsa)"

  alias su="/bin/su -"
  alias ls="ls -F --color=auto"
  alias open="xdg-open"
elif [ "$WINDOWS" ]
then
  quiet_which plink && alias ssh='plink -l $(git config shell.username)'

  alias ls="ls -F --color=auto"

  open() {
    # shellcheck disable=SC2145
    cmd /C"$@"
  }
fi

# Set up editor
if [ -z "${SSH_CONNECTION}" ] && quiet_which atom
then
  export EDITOR="atom"
  export GIT_EDITOR="$EDITOR -w"
  export SVN_EDITOR=$GIT_EDITOR
elif quiet_which vim
then
  export EDITOR="vim"
elif quiet_which vi
then
  export EDITOR="vi"
fi

if [ -z "${SSH_CONNECTION}" ] && quiet_which gpgconf
then
  # Enable gpg-agent if it is not running
  GPG_AGENT_SOCKET="$(gpgconf --list-dirs agent-ssh-socket)"
  if [ ! -S $GPG_AGENT_SOCKET ]; then
    gpg-agent --daemon >/dev/null 2>&1
    export GPG_TTY=$(tty)
  fi

  # Set SSH to use gpg-agent if it is configured to do so
  GPG_SSH_SUPPORT=$(gpgconf --list-options gpg-agent | grep enable-ssh-support | cut -d : -f 10)
  if [ -n "$GPG_SSH_SUPPORT" ]
  then
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK=$GPG_AGENT_SOCKET
    # launchctl setenv SSH_AUTH_SOCK $GPG_AGENT_SOCKET
  fi
fi

# Run dircolors if it exists
quiet_which dircolors && eval "$(dircolors -b)"

# Save directory changes
cd() {
  builtin cd "$@" || return
  [ "$TERMINALAPP" ] && which set_terminal_app_pwd &>/dev/null \
    && set_terminal_app_pwd
  pwd > "$HOME/.lastpwd"
  ls
}

# Pretty-print JSON files
json() {
  [ -n "$1" ] || return
  jsonlint "$1" | jq .
}

# Pretty-print Homebrew install receipts
receipt() {
  [ -n "$1" ] || return
  json "$HOMEBREW_PREFIX/opt/$1/INSTALL_RECEIPT.json"
}

# Move files to the Trash folder
trash() {
  mv "$@" "$HOME/.Trash/"
}

# GitHub API shortcut
github-api-curl() {
  curl -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/$1"
}
alias github-api-curl="noglob github-api-curl"
