#!/bin/bash
PORT=$((5900 + $RANDOM % 10000))
PASS=$(openssl rand -hex 12)

krfb-virtualmonitor --resolution "1920x1200" --name "sunshine" --port "$PORT" --password "$PASS"
