#!/usr/bin/env bash

for instance in $(qdbus-qt6 | grep org.kde.konsole); do
	for session in $(qdbus-qt6 "$instance" | grep -E '^/Sessions/'); do
		qdbus-qt6 "$instance" "$session" org.kde.konsole.Session.setProfile "Dark"
	done

	for window in $(qdbus-qt6 "$instance" | grep -E '^/Windows/'); do
		qdbus-qt6 "$instance" "$window" org.kde.konsole.Window.setDefaultProfile "Dark"
	done
done
