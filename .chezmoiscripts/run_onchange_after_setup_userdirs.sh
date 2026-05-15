#!/usr/bin/env bash

# user-dirs.dirs hash: {{ include "dot_config/user-dirs.dirs" | sha256sum }}

normalize_dir() {
    local src="$1"
    local dst="$2"

    if [[ -d "$src" && ! -d "$dst" ]]; then
        mv "$src" "$dst"
    fi

    mkdir -p "$dst"
}

normalize_dir "$HOME/Downloads" "$HOME/downloads"
normalize_dir "$HOME/Documents" "$HOME/documents"
normalize_dir "$HOME/Pictures" "$HOME/pictures"
normalize_dir "$HOME/Music" "$HOME/music"
normalize_dir "$HOME/Videos" "$HOME/videos"
normalize_dir "$HOME/Desktop" "$HOME/desktop"
normalize_dir "$HOME/Templates" "$HOME/templates"
normalize_dir "$HOME/Public" "$HOME/public"

xdg-user-dirs-update
