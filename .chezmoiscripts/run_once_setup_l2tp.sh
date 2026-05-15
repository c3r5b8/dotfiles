#!/usr/bin/env bash

file="/etc/modprobe.d/l2tp_eth-blacklist.conf"
required=$(
    cat <<EOF
# blacklist l2tp_eth
EOF
)
perms="0644"

if [[ "$(sudo cat "$file" 2>/dev/null)" != "$required" ]]; then
    echo "$required" | sudo tee "$file" >/dev/null
    sudo chmod "$perms" "$file"
    echo "created $file file"
fi

file="/etc/modprobe.d/l2tp_netlink-blacklist.conf"
required=$(
    cat <<EOF
# blacklist l2tp_netlink
EOF
)
perms="0644"

if [[ "$(sudo cat "$file" 2>/dev/null)" != "$required" ]]; then
    echo "$required" | sudo tee "$file" >/dev/null
    sudo chmod "$perms" "$file"
    echo "created $file file"
fi

file="/etc/modprobe.d/l2tp_ppp-blacklist.conf"
required=$(
    cat <<EOF
# blacklist l2tp_ppp
EOF
)
perms="0644"

if [[ "$(sudo cat "$file" 2>/dev/null)" != "$required" ]]; then
    echo "$required" | sudo tee "$file" >/dev/null
    sudo chmod "$perms" "$file"
    echo "created $file file"
fi
