#!/bin/bash
# shellcheck disable=SC1091

# check if this is a login shell
[ "$0" = "-bash" ] && export LOGIN_BASH="1"

# run bash_profile if this is not a login shell
# shellcheck source=bash_profile.sh
[ -z "$LOGIN_BASH" ] && source ~/.bash_profile

# load shared shell configuration
# shellcheck source=shrc.sh
source ~/.shrc

# History
export HISTFILE=~/.bash_history
export HISTCONTROL=ignoredups:ignorespace
export HISTIGNORE="&:ls:[bf]g:exit"

# The next line updates PATH for the Google Cloud SDK.
if [ -f "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc" ]; then . "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc" ]; then . "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"; fi
