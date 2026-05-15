#!/usr/bin/env bash

mkdir -p ~/.local/share/fonts

if [[ ! -d "$HOME/.local/share/fonts/FiraCode" ]]; then
    echo "installing FiraCode Nerd Font"

    wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip -O /tmp/FiraCode.zip
    unzip -q /tmp/FiraCode.zip -d ~/.local/share/fonts/FiraCode
    rm /tmp/FiraCode.zip
fi

if [[ ! -d "$HOME/.local/share/fonts/Fira" ]]; then
    git clone https://github.com/mozilla/Fira.git
    mkdir -p "$HOME/.local/share/fonts/Fira"
    cp Fira/ttf/* "$HOME/.local/share/fonts/Fira"
    rm -rf Fira
fi


fc-cache -fv
