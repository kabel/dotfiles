#!/bin/sh
# shellcheck disable=SC2155,SC1091

# Colourful manpages
export LESS_TERMCAP_mb="$(tput bold)$(tput setaf 1)"
export LESS_TERMCAP_md="$(tput bold)$(tput setaf 1)"
export LESS_TERMCAP_me="$(tput sgr0)"
export LESS_TERMCAP_se="$(tput sgr0)"
export LESS_TERMCAP_so="$(tput bold)$(tput setaf 3)$(tput setab 4)"
export LESS_TERMCAP_ue="$(tput sgr0)"
export LESS_TERMCAP_us="$(tput bold)$(tput setaf 2)"

# Set to avoid `env` output from changing console colour
export LESS_TERMEND="$(tput sgr0)"

# Setup paths
remove_from_path() {
  [ -d "$1" ] || return
  PATHSUB=":$PATH:"
  # shellcheck disable=SC3060
  PATHSUB=${PATHSUB//:$1:/:}
  PATHSUB=${PATHSUB#:}
  PATHSUB=${PATHSUB%:}
  export PATH="$PATHSUB"
}

add_to_path_start() {
  [ -d "$1" ] || return
  echo "$PATH" | grep -qe "^$1:" && return
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

add_to_path_end() {
  [ -d "$1" ] || return
  echo "$PATH" | grep -qe ":$1$" && return
  remove_from_path "$1"
  export PATH="$PATH:$1"
}

force_add_to_path_start() {
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

quiet_which() {
  command -v "$1" 1>/dev/null 2>&1
}

add_to_path_end "$HOME/bin"
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
alias less="less -iRFX"
alias rsync="rsync --partial --progress --human-readable --compress"
alias rg="rg --colors 'match:style:nobold' --colors 'path:style:nobold'"
alias gist="gist --open --copy"
alias sha256="shasum -a 256"
alias sourcerc="source ~/.bash_profile && source ~/.zshrc"
alias usebash="chsh -s /bin/bash"
alias usezsh="chsh -s /bin/zsh"
alias yarnr="find . -type d -name node_modules -prune -exec rm -rf {} \; && yarn"
alias yarnu="yarn upgrade-interactive --latest"
alias yarnv=yarnVersion

# validate cd enhanced requirements
quiet_which jabba || export CD_USE_JABBA=""
quiet_which nvm || export CD_USE_NVM=""

#nvm settings
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"

# Platform-specific stuff
if quiet_which brew
then
  export HOMEBREW_PREFIX="$(brew --prefix)"
  export HOMEBREW_REPOSITORY="$(brew --repo)"
  export HOMEBREW_AUTO_UPDATE_SECS=3600
  export HOMEBREW_DEVELOPER=1
  export HOMEBREW_PRY=1

  alias hbc='cd $HOMEBREW_REPOSITORY/Library/Taps/homebrew/homebrew-core'
fi

if [ "$MACOS" ]
then
  export GREP_OPTIONS="--color=auto"
  export CLICOLOR="1"

  # add_to_path_end /Applications/Xcode.app/Contents/Developer/usr/bin
  # add_to_path_end /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
  add_to_path_end "$HOMEBREW_PREFIX/opt/git/share/git-core/contrib/diff-highlight"
  add_to_path_end "$HOMEBREW_PREFIX/Homebrew/Library/Homebrew/shims/gems"

  if quiet_which diff-highlight
  then
    # shellcheck disable=SC2016
    export GIT_PAGER='diff-highlight | less -+$LESS -RXF'
  else
    # shellcheck disable=SC2016
    export GIT_PAGER='less -+$LESS -RXF'
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

  alias ql="qlmanage -p 1>/dev/null"
  alias locate="mdfind -name"
  alias cpwd="pwd | tr -d '\\n' | pbcopy"
  alias finder-hide="setfile -a V"

  # Old default Curl is broken for Git on Leopard.
  # shellcheck disable=SC3028
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
if [ -z "${SSH_CONNECTION}" ] && quiet_which code
then
  export EDITOR="code"
  export GIT_EDITOR="$EDITOR -w"
  export SVN_EDITOR="$GIT_EDITOR"
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
  if [ ! -S "$GPG_AGENT_SOCKET" ]; then
    gpg-agent --daemon >/dev/null 2>&1
    export GPG_TTY="$(tty)"
  fi

  # Set SSH to use gpg-agent if it is configured to do so
  GPG_SSH_SUPPORT=$(gpgconf --list-options gpg-agent 2>/dev/null | grep enable-ssh-support | cut -d : -f 10)
  if [ -n "$GPG_SSH_SUPPORT" ]
  then
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK="$GPG_AGENT_SOCKET"
    # launchctl setenv SSH_AUTH_SOCK $GPG_AGENT_SOCKET
  fi
fi

# Run dircolors if it exists
quiet_which dircolors && eval "$(dircolors -b)"
quiet_which gdircolors && eval "$(gdircolors -b)"

# Save directory changes
cd() {
  builtin cd "$@" || return
  [ -n "$CD_SAVE_LASTPWD" ] && pwd > "$HOME/.lastpwd"
  [ -n "$CD_USE_JABBA" ] && useJabbarc
  [ -n "$CD_USE_NVM" ] && useNvmrc
  [ -n "$CD_DO_LS" ] && ls
}

useNvmrc() {
  [ -f .nvmrc ] && nvm use
}

useJabbarc() {
  if [ -f .jabbarc ]; then
    jabba install
    jabba use
  fi
}

gitUpstream() {
  CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  git checkout master
  git fetch upstream
  git rebase upstream/master
  git push origin master
  git checkout "${CURRENT_BRANCH}"
}

gitPullRequest() {
  remote=${2:-origin}
  git fetch "${remote}" "+refs/pull/$1/head:refs/remotes/${remote}/pr/$1"
  git pull --no-rebase --squash "${remote}" "pull/$1/head"
}

gitPullRequestUpstream() {
  git reset --hard
  gitUpstream
  remote=${2:-upstream}
  git fetch "${remote}" "+refs/pull/$1/head:refs/remotes/${remote}/pr/$1"
  git pull --no-rebase --squash "${remote}" "pull/$1/head"
}

killport() {
  port=$(lsof -n "-i4TCP:$1" | grep LISTEN | awk '{ print $2 }')
  kill -9 "$port"
}

yarnVersion() {
    echo "Uninstalling yarn..."
    rm -f /usr/local/bin/yarnpkg
    rm -f /usr/local/bin/yarn

    echo "Removing yarn cache..."
    if [ -z ${YARN_CACHE_FOLDER+x} ]; then
        rm -rf "${YARN_CACHE_FOLDER}"
    else
        rm -rf "${HOME}/.yarn"
    fi

    echo "Installing yarn..."
    curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version "$1"
}

# Pretty-print JSON files
json() {
  [ -n "$1" ] || return
  jsonlint "$1" | jq .
}

# Move files to the Trash folder
trash() {
  mv "$@" "$HOME/.Trash/"
}

# GitHub API shortcut
github_api_curl_() {
  curl -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/$1"
}
alias github_api_curl="noglob github-api-curl_"

code_backup() {
  code --list-extensions > "$HOME/.config/Code/User/Extensionsfile"
}

code_restore() {
  # shellcheck disable=SC2002
  cat "$HOME/.config/Code/User/Extensionsfile" | xargs -n1 code --install-extension
}
