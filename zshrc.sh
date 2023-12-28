#!/bin/bash
# shellcheck disable=SC1091

# run zprofile if this is not a login shell
# shellcheck source=zprofile.sh
[[ ! -o login ]] && source ~/.zprofile

# load shared shell configuration
# shellcheck source=shrc.sh
source ~/.shrc

# Correct minor directory changing spelling mistakes
setopt CORRECT_ALL

# completion
autoload -Uz compinit
compinit

# Colorful prompt
USER_COLOR="%B%F{white}"
HOST_COLOR="%B%F{blue}"
RESET_COLOR="%f%b"
BACK_GREY_COLOR="%K{#2d363b}"
FORE_GREY_COLOR="%F{#2d363b}"

# Terminal.app only supports 256 colors
if [ -n "$TERMINALAPP" ]
then
  BACK_GREY_COLOR="%K{237}"
  FORE_GREY_COLOR="%F{237}"
fi

if [ "$USER" = "root" ]
then
  USER_COLOR="%B%F{magenta}"
fi

if [ -n "${SSH_CONNECTION}" ]
then
  HOST_COLOR="%B%F{cyan}"
fi

setopt prompt_subst
PS1_PREFIX="${BACK_GREY_COLOR} ${USER_COLOR}%n${RESET_COLOR}@${HOST_COLOR}%M${RESET_COLOR} %k${FORE_GREY_COLOR}%f %3~ "
PS1_SUFFIX=$'\n'"%# "
PS1="${PS1_PREFIX}${PS1_SUFFIX}"

unset USER_COLOR
unset HOST_COLOR
unset RESET_COLOR
unset BACK_GREY_COLOR
unset FORE_GREY_COLOR

autoload -Uz vcs_info
vcs_info_msg_0_=
vcs_info_msg_1_=
vcs_info_msg_2_=
my_vcs_prompt() {
    local GIT_REPO_INFO
    GIT_REPO_INFO="$(git rev-parse --is-inside-git-dir --is-bare-repository 2>/dev/null)"
    if [[ "$GIT_REPO_INFO" == true* ]]
    then
      vcs_info_msg_0_="GIT_DIR!"
      if [[ "$GIT_REPO_INFO" == true?true ]]
      then 
        vcs_info_msg_0_="$(git symbolic-ref HEAD 2>/dev/null)"
        vcs_info_msg_0_="BARE:${vcs_info_msg_0_##refs/heads/}"
      fi
    else
      vcs_info
    fi
    
    local changes=""
    [[ -n ${vcs_info_msg_1_} ]] && changes=" $vcs_info_msg_1_"
    if [[ -n ${vcs_info_msg_0_} ]]
    then
      PS1="${PS1_PREFIX}%F{green}%S%s%f%K{green}%F{black}  ${vcs_info_msg_0_}${vcs_info_msg_2_:u}${changes} %f%k%F{green}%f ${PS1_SUFFIX}"
    else
      PS1="${PS1_PREFIX}${PS1_SUFFIX}"
    fi
}
precmd_functions+=(my_vcs_prompt)

zstyle ':vcs_info:*' max-exports 3
zstyle ':vcs_info:git*' formats "%b" "%u%c"
zstyle ':vcs_info:git*' actionformats "%b" "%u%c" "|%a %m"
zstyle ':vcs_info:git*' stagedstr "+"
zstyle ':vcs_info:git*' unstagedstr "*"
zstyle ':vcs_info:git*' check-for-changes true
zstyle ':vcs_info:git*' check-for-staged-changes true
zstyle ':vcs_info:git*' patch-format "%n/%a"
zstyle ':vcs_info:git*' nopatch-format "%n/%a"

# History
export HISTFILE=~/.zsh_history
export HISTORY_IGNORE="(&|ls|bg|fg|exit)"
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS

# iTerm2 Integration
if [ -n "$ITERMAPP" ]
then
  source "$HOME/.iterm2_shell_integration.zsh"
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" ]; then . "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc" ]; then . "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"; fi

#fix home/end keys
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line