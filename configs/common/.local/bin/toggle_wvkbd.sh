#!/bin/bash

set -eu

if ! pgrep "wvkbd" >/dev/null; then
	~/.local/bin/wvkbd --landscape-layers full,cyrillic -l full,cyrillic --hidden &
fi

pkill -34 "wvkbd"
