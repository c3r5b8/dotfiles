#!/usr/bin/env bash

if [[ ! -f "$HOME/.local/bin/ssh-to-age" ]]; then
    GOPATH="$HOME/.local/share/go" GOBIN="$HOME/.local/bin" "$HOME/.go/bin/go" install github.com/Mic92/ssh-to-age/cmd/ssh-to-age@latest
fi

if [[ ! -f "$HOME/.config/age/keys.txt" ]]; then
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        mkdir -p "$HOME/.config/age"
        "$HOME/.local/bin/ssh-to-age" -private-key -i "$HOME/.ssh/id_ed25519" >"$HOME/.config/age/keys.txt"
    else
        echo "add ssh key first"
        exit 1
    fi
fi
