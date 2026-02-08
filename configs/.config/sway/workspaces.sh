#!/bin/sh
if [ -z "$1" ]; then
  echo "Usage: $0 <workspace-number> [move]"
  exit 1
fi

current_output=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.focused) | .name')

if [ "$current_output" = "eDP-1" ]; then
  workspace_number="$1"
elif [ "$current_output" = "HDMI-A-1" ]; then
  workspace_number=$((10 + $1))
elif echo "$current_output" | grep -q '^HEADLESS'; then
  workspace_number=$((20 + $1))
else
  echo "Unknown output: $current_output"
  exit 1
fi

if [ "$2" = "move" ]; then
  swaymsg move container to workspace number "$workspace_number"
else
  swaymsg workspace number "$workspace_number"
fi

