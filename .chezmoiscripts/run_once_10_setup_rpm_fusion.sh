#!/usr/bin/env bash

if ! rpm -q --quiet rpmfusion-free-release || ! rpm -q --quiet rpmfusion-nonfree-release; then
    sudo rpm-ostree install --apply-live -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
fi
sudo rpm-ostree update --uninstall rpmfusion-free-release --uninstall rpmfusion-nonfree-release \
                      --install rpmfusion-free-release --install rpmfusion-nonfree-release 2>/dev/null || true
