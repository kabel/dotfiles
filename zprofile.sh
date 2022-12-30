#!/bin/bash
# shellcheck disable=SC1091

# load shared shell configuration
# shellcheck source=shprofile.sh
source ~/.shprofile

# Enable history appending instead of overwriting.
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
