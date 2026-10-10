#!/usr/bin/env bash

if [[ ! -d $HOME/.local/share/icons/Papirus/ ]]; then
    wget -qO- https://git.io/papirus-icon-theme-install | env DESTDIR="$HOME/.local/share/icons" sh
fi

if [[ ! -f $HOME/.local/bin/papirus-folders ]]; then
    wget -qO- https://git.io/papirus-folders-install | env PREFIX="$HOME/.local" sh
    $HOME/.local/bin/papirus-folders -C green -t Papirus
fi
