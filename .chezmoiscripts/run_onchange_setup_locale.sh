#!/usr/bin/env bash

file="/etc/locale.conf"
required=$(
    cat <<EOF
    LANG="en_US.UTF-8"
    LC_TIME="en_IE.UTF-8"
EOF
)
perms="0644"

if [[ "$(sudo cat "$file" 2>/dev/null)" != "$required" ]]; then
    echo "$required" | sudo tee "$file" >/dev/null
    sudo chmod "$perms" "$file"
    echo "created $file file"
fi
