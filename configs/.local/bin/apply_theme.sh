#!/usr/bin/env bash

THEME_FILE="$HOME/.current_theme"

if [ -f "$THEME_FILE" ]; then
	theme=$(cat "$THEME_FILE")

	if [[ $theme == "light" ]]; then
		pkill -10 foot
		echo "Applied light theme."
	elif [[ $theme == "dark" ]]; then
		pkill -12 foot
		echo "Applied dark theme."
	else
		echo "Invalid theme in file: $theme"
		exit 1
	fi
else
	echo "No theme file found: $THEME_FILE"
	exit 1
fi
