#!/bin/sh
[ -n "$CD_SAVE_LASTPWD" ] && [ "$(pwd)" != '/' ] && pwd > ~/.lastpwd
