#!/usr/bin/env bash

# user-dirs.dirs hash: {{ include "dot_config/user-dirs.dirs" | sha256sum }}

rm_dir() {
    local dir="$1"

    if [[ -d "$dir" ]]; then
        rm -rf "$dir"
    fi
}

rm_dir "$HOME/Downloads"
rm_dir "$HOME/Documents"
rm_dir "$HOME/Pictures"
rm_dir "$HOME/Music"
rm_dir "$HOME/Videos"
rm_dir "$HOME/Desktop"
rm_dir "$HOME/Templates"
rm_dir "$HOME/Public"

xdg-user-dirs-update
