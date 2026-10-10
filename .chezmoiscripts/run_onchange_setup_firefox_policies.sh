#!/usr/bin/env bash

file="/etc/firefox/policies/policies.json"
required=$(
    cat <<EOF
{
  "policies": {
    "SearchEngines": {
      "Default": "DuckDuckGo"
    }
  }
}
EOF
)
perms="0644"

if [[ "$(sudo cat "$file" 2>/dev/null)" != "$required" ]]; then
    sudo mkdir -p /etc/firefox/policies/
    echo "$required" | sudo tee "$file" >/dev/null
    sudo chmod "$perms" "$file"
    echo "created $file file"
fi
