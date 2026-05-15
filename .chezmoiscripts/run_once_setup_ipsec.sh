#!/usr/bin/env bash

file="/etc/ipsec.d/ikev1.conf"
required=$(
    cat <<EOF
config setup
        ikev1-policy=accept
EOF
)
perms="0640"

if [[ "$(sudo cat "$file" 2>/dev/null)" != "$required" ]]; then
    sudo mkdir -p /etc/ipsec.d/
    echo "$required" | sudo tee "$file" >/dev/null
    sudo chmod "$perms" "$file"
    echo "created $file file"
fi
