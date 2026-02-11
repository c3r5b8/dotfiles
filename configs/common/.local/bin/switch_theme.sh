#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config"
THEME_FILE="$HOME/.current_theme"

# Function to set the theme
set_theme() {
	local theme=$1

	# bat
	ln -sf "$CONFIG_DIR/bat/config_$theme" "$CONFIG_DIR/bat/config"

	# btop
	ln -sf "$CONFIG_DIR/btop/btop_$theme.conf" "$CONFIG_DIR/btop/btop.conf"
	pkill -12 btop

	# dunst
	ln -sf "$CONFIG_DIR/dunst/dunstrc_$theme" "$CONFIG_DIR/dunst/dunstrc"
	pkill dunst

	# fuzzel
	ln -sf "$CONFIG_DIR/fuzzel/$theme.ini" "$CONFIG_DIR/fuzzel/theme.ini"

	# imv
	ln -sf "$CONFIG_DIR/imv/config_$theme" "$CONFIG_DIR/imv/config"

	# waybar
	ln -sf "$CONFIG_DIR/waybar/$theme.css" "$CONFIG_DIR/waybar/theme.css"

	# sway
	ln -sf "$CONFIG_DIR/sway/theme_$theme" "$CONFIG_DIR/sway/theme"
	swaymsg reload

	# foot signal
	if [[ $theme == "light" ]]; then
		pkill -10 foot
	elif [[ $theme == "dark" ]]; then
		pkill -12 foot
	fi

	# papirus-folders
	if [[ $theme == "light" ]]; then
		$HOME/.local/bin/papirus-folders -C cat-latte-green -t Papirus-Light &
	elif [[ $theme == "dark" ]]; then
		$HOME/.local/bin/papirus-folders -C cat-mocha-green -t Papirus-Dark &
	fi

	# Write current theme to file
	echo "$theme" >"$THEME_FILE"

	echo "Switched to $theme theme."
}

if [ $# -ne 1 ]; then
	echo "Usage: $0 [dark|light|toggle]"
	exit 1
fi

action=$1

case $action in
dark)
	set_theme "dark"
	;;
light)
	set_theme "light"
	;;
toggle)
	if [ -f "$THEME_FILE" ]; then
		current=$(cat "$THEME_FILE")
		if [ "$current" == "dark" ]; then
			set_theme "light"
		else
			set_theme "dark"
		fi
	else
		set_theme "light"
	fi
	;;
*)
	echo "Invalid argument: $action. Use dark, light, or toggle."
	exit 1
	;;
esac
