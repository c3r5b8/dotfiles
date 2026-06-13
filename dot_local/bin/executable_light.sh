#!/usr/bin/env bash

for instance in $(qdbus-qt6 | grep org.kde.konsole); do
	for session in $(qdbus-qt6 "$instance" | grep -E '^/Sessions/'); do
		qdbus-qt6 "$instance" "$session" org.kde.konsole.Session.setProfile "Light"
	done

	for window in $(qdbus-qt6 "$instance" | grep -E '^/Windows/'); do
		qdbus-qt6 "$instance" "$window" org.kde.konsole.Window.setDefaultProfile "Light"
	done
done

ln -sf "/var/home/c3r5b8/.config/btop/themes/light.theme" "/var/home/c3r5b8/.config/btop/themes/current_theme.theme"
pkill -12 btop || true
