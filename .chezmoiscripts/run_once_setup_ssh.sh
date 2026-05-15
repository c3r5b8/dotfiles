#!/usr/bin/env bash

if ! systemctl is-enabled --quiet "sshd"; then
    sudo systemctl enable --now "sshd"
fi
