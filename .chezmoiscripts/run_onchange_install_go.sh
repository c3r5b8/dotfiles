#!/usr/bin/env bash

if [[ ! -f "$HOME/.go/bin/go" ]]; then
    GO_TARBALL="$(curl -fsSL https://go.dev/dl/?mode=json 2>/dev/null | jq -r '.[0].version // empty').linux-amd64.tar.gz"
    GO_URL="https://go.dev/dl/$(curl -fsSL https://go.dev/dl/?mode=json 2>/dev/null | jq -r '.[0].version // empty').linux-amd64.tar.gz"

    curl -fsSL "$GO_URL" -o "/tmp/$GO_TARBALL"
    mkdir -p "$HOME/.go"
    tar -C "$HOME/.go" -xzf "/tmp/$GO_TARBALL" --strip-components=1
    mkdir -p "$HOME/.local/share/go"
fi
