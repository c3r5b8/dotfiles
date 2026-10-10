#!/usr/bin/env bash

file="/etc/plasmalogin.conf.d/autologin.conf"
required=$(
    cat <<EOF
[Autologin]
User=c3r5b8
Session=plasma.desktop
EOF
)
perms="0644"

if [[ "$(sudo cat "$file" 2>/dev/null)" != "$required" ]]; then
    echo "$required" | sudo tee "$file" >/dev/null
    sudo chmod "$perms" "$file"
    echo "created $file file"
fi
