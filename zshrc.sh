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

if [ "$USER" = "root" ]
then
  USER_COLOR="%B%F{magenta}"
fi

if [ -n "${SSH_CONNECTION}" ]
then
  HOST_COLOR="%B%F{cyan}"
fi

setopt prompt_subst
PS1_PREFIX="${USER_COLOR}%n${RESET_COLOR}@${HOST_COLOR}%M$RESET_COLOR %1~"
PS1_SUFFIX=$'\n'"%# "
PS1="${PS1_PREFIX}${PS1_SUFFIX}"

unset USER_COLOR
unset HOST_COLOR
unset RESET_COLOR

autoload -Uz vcs_info
vcs_info_msg_0_=
vcs_info_msg_1_=
vcs_info_msg_2_=
my_vcs_prompt() {
    vcs_info
    local changes=""
    [[ -n ${vcs_info_msg_1_} ]] && changes=" $vcs_info_msg_1_"
    [[ -n ${vcs_info_msg_0_} ]] && PS1="${PS1_PREFIX} (${vcs_info_msg_0_}${vcs_info_msg_2_:u}${changes})${PS1_SUFFIX}"
}
precmd_functions+=(my_vcs_prompt)

zstyle ':vcs_info:*' max-exports 3
zstyle ':vcs_info:git*' formats "%%F{green}%b%%f" "%u%c"
zstyle ':vcs_info:git*' actionformats "%%F{green}%b%%f" "%u%c" "|%a %m"
zstyle ':vcs_info:git*' stagedstr "%F{green}+%f"
zstyle ':vcs_info:git*' unstagedstr "%F{red}*%f"
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
