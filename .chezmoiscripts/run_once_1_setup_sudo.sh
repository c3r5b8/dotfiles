#!/usr/bin/env bash

file="/etc/sudoers.d/00_c3r5b8"
required="c3r5b8 ALL=(ALL:ALL) NOPASSWD: ALL"
perms="0440"

if [[ "$(sudo cat "$file" 2>/dev/null)" != "$required" ]]; then
    echo "$required" | sudo tee "$file" >/dev/null
    sudo chmod "$perms" "$file"
    echo "created $file file"
fi
