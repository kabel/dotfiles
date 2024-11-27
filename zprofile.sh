#!/bin/bash
# shellcheck disable=SC1091

# load shared shell configuration
# shellcheck source=shprofile.sh
source ~/.shprofile

# Enable history appending instead of overwriting.
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# Added by OrbStack: command-line tools and integration
# Comment this line if you don't want it to be added again.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
