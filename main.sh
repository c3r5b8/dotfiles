#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

trap 'die "command failed: $BASH_COMMAND (line $LINENO)"' ERR

die() {
    echo "ERROR: $*" >&2
    exit 1
}

set_file() {
    local file="$1"
    local required="$2"
    local perms="$3"

    if [[ "$(sudo cat "$file" 2>/dev/null)" != "$required" ]]; then
        echo "$required" | sudo tee "$file" >/dev/null
        sudo chmod "$perms" "$file"
        echo "created $file file"
    fi
}

add_repo() {
    if [[ ! -f "/etc/yum.repos.d/$1" ]]; then
        sudo curl -fsSL \
            "$2" \
            -o "/etc/yum.repos.d/$1"
        echo "added $1 repo"
    fi
}

install_flatpak() {
    if ! grep -qx "$1" <<<"$INSTALLED_FLATPAKS"; then
        flatpak install flathub "$1" -y
        echo "installed $1"
    fi
}

download_from_github() {
    local api="$1"
    local regex="$2"
    local url

    url="$(
        curl -fsSL "$api" |
            grep -E "browser_download_url.*$regex" |
            head -n1 |
            cut -d '"' -f 4
    )"

    [[ -n "$url" ]] || die "No GitHub asset matched: $regex"

    curl -fL -O "$url"
}

enable_service() {
    if ! systemctl is-enabled --quiet "$1"; then
        sudo systemctl enable --now "$1"
        echo "enabled and started $1"
    fi
}

normalize_dir() {
    local src="$1"
    local dst="$2"

    if [[ -d "$src" && ! -d "$dst" ]]; then
        mv "$src" "$dst"
    fi

    mkdir -p "$dst"
}

download_wallpaper() {
    local wallpaper_dir="$HOME/pictures/wallpapers/$1"
    local mf_url="$2"

    if [[ ! -d "$wallpaper_dir" ]]; then
        echo "Downloading wallpapers…"
        mkdir -p "$wallpaper_dir"
        local dl_link=""
        dl_link="$(curl -fsSL "$mf_url" |
            grep -oE 'https://download[^"]+' |
            head -n 1)"

        if [[ -z "$dl_link" ]]; then
            die "Could not resolve MediaFire direct link"
        fi
        curl -fsSL -o wallpaper.zip "$dl_link"
        unzip -o wallpaper.zip -d "$wallpaper_dir"
        find "$wallpaper_dir" -mindepth 2 -type f -exec mv {} "$wallpaper_dir/" \;
        find "$wallpaper_dir" -mindepth 1 -type d -empty -delete
        rm -f wallpaper.zip

        echo "Wallpapers installed in $wallpaper_dir"
    fi
}

create_link() {
    local source="$1"
    local destination="$2"
    if ! [[ -L "$destination" && "$(readlink -f "$destination")" = "$(readlink -f "$source")" ]]; then
        rm -rf "$destination" 2>/dev/null
        mkdir -p "$(dirname "$destination")"
        ln -sf "$source" "$destination"
        echo "$destination -> linked"
    fi
}

FEDORA_VER="$(rpm -E %fedora)"
RPM_JSON="$(rpm-ostree status --json)"
INSTALLED_FLATPAKS="$(flatpak list --app --columns=application)"
FONT_BASE="$HOME/.local/share/fonts"

set_file "/etc/sudoers.d/00_c3r5b8" "c3r5b8 ALL=(ALL:ALL) NOPASSWD: ALL" "0440"
sddm_config=$(
    cat <<EOF
    [Autologin]
    User=c3r5b8
    Session=sway
EOF
)
set_file "/etc/sddm.conf.d/autologin.conf" "$sddm_config" "0644"

if ! echo "$RPM_JSON" | jq -r '
    .deployments[0]["requested-local-packages"][]?,
    .deployments[0]["requested-packages"][]?
' | grep -q '^rpmfusion-'; then
    sudo rpm-ostree install --apply-live -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"${FEDORA_VER}".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"${FEDORA_VER}".noarch.rpm
    echo "installed rpmfusion"
    RPM_JSON="$(rpm-ostree status --json)"
fi

if echo "$RPM_JSON" | jq -r '.deployments[0].["requested-local-packages"][]' | grep -q rpmfusion; then
    sudo rpm-ostree update \
        --uninstall rpmfusion-free-release \
        --uninstall rpmfusion-nonfree-release \
        --install rpmfusion-free-release \
        --install rpmfusion-nonfree-release
    RPM_JSON="$(rpm-ostree status --json)"
fi

if [[ ! -f "/etc/yum.repos.d/cider.repo" ]]; then
    sudo cp ./files/cider.repo /etc/yum.repos.d/cider.repo
    echo "added cider repo"
fi

add_repo tailscale.repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo
add_repo atim-starship-fedora-"${FEDORA_VER}".repo https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora-"${FEDORA_VER}"/atim-starship-fedora-"${FEDORA_VER}".repo
add_repo lihaohong-yazi-fedora-"${FEDORA_VER}".repo https://copr.fedorainfracloud.org/coprs/lihaohong/yazi/repo/fedora-"${FEDORA_VER}"/lihaohong-yazi-fedora-"${FEDORA_VER}".repo
add_repo peterwu-rendezvous-fedora-"${FEDORA_VER}".repo https://copr.fedorainfracloud.org/coprs/peterwu/rendezvous/repo/fedora-"${FEDORA_VER}"/peterwu-rendezvous-fedora-"${FEDORA_VER}".repo

REQUIRED=(
    gstreamer1-plugins-bad-free-extras
    gstreamer1-plugins-bad-freeworld
    gstreamer1-plugins-ugly
    gstreamer1-vaapi
    age
    android-tools
    bat
    bibata-cursor-themes
    btop
    Cider
    clang
    fastfetch
    fd-find
    fish
    fzf
    gcc
    git
    go
    gparted
    inkscape
    iperf3
    libreoffice
    make
    neovim
    nmap
    nvtop
    nodejs
    nodejs-npm
    onefetch
    p7zip
    qbittorrent
    rclone
    ripgrep
    krita
    starship
    fuzzel
    syncthing
    tailscale
    telegram-desktop
    thunderbird
    tokei
    wireshark
    xxd
    zoxide
    yazi
    stow
)

REMOVE_IGNORE=(ffmpeg rpmfusion-free-release rpmfusion-nonfree-release)

if [[ "$HOSTNAME" == "antares" || "$HOSTNAME" == "shaula" ]]; then
    REQUIRED+=("intel-media-driver" "igt-gpu-tools")
fi

if [[ "$HOSTNAME" == "acrab" ]]; then
    REQUIRED+=("mesa-vdpau-drivers-freeworld")
    if ! echo "$RPM_JSON" | jq -r '.deployments[0]."requested-base-removals"[]?' | grep -Fxq "mesa-va-drivers"; then
        echo "Applying override: remove mesa-va-drivers, install mesa-va-drivers-freeworld"
        sudo rpm-ostree override remove mesa-va-drivers --install mesa-va-drivers-freeworld
        echo "Reboot required for override"
        RPM_JSON=$(rpm-ostree status --json) # Refresh JSON after change
    fi
fi

mapfile -t CURRENT < <(echo "$RPM_JSON" | jq -r '.deployments[0].packages // [] | .[]' | sort -u)

mapfile -t REQ_SORTED < <(printf '%s\n' "${REQUIRED[@]}" | sort -u)

mapfile -t TO_INSTALL < <(comm -23 <(printf '%s\n' "${REQ_SORTED[@]}") <(printf '%s\n' "${CURRENT[@]}"))
mapfile -t TO_REMOVE < <(comm -13 <(printf '%s\n' "${REQ_SORTED[@]}") <(printf '%s\n' "${CURRENT[@]}"))
mapfile -t TO_REMOVE < <(comm -13 <(printf '%s\n' "${REMOVE_IGNORE[@]}") <(printf '%s\n' "${TO_REMOVE[@]}"))

# Summary
if [[ "${#TO_REMOVE[@]}" -gt 0 || "${#TO_INSTALL[@]}" -gt 0 ]]; then
    matching=$(comm -12 <(printf '%s\n' "${REQ_SORTED[@]}") <(printf '%s\n' "${CURRENT[@]}") | wc -l)
    echo "Packages already matching: $matching"
    echo "Total required: ${#REQ_SORTED[@]}"
    echo "Total currently layered: ${#CURRENT[@]}"
    echo "${TO_INSTALL[@]}"
    echo "${TO_REMOVE[@]}"
fi

if [[ "${#TO_REMOVE[@]}" -gt 0 ]]; then
    echo "Uninstalling extra packages: ${TO_REMOVE[*]}"
    sudo rpm-ostree uninstall "${TO_REMOVE[@]}"
    echo "reboot required"
    RPM_JSON="$(rpm-ostree status --json)"
fi

if [[ "${#TO_INSTALL[@]}" -gt 0 ]]; then
    echo "Installing missing packages: ${TO_INSTALL[*]}"
    sudo rpm-ostree install "${TO_INSTALL[@]}"
    echo "reboot required"
    RPM_JSON="$(rpm-ostree status --json)"
fi

if [[ "$HOSTNAME" == "shaula" ]]; then
    INITRAMFS_ENABLED="$(echo "$RPM_JSON" | jq -r '.deployments[0]["regenerate-initramfs"]')"
    if [[ "$INITRAMFS_ENABLED" != "true" ]]; then
        sudo rpm-ostree initramfs --enable
        echo "enabled initramfs regeneration"
        echo "reboot required"
    fi
    if ! echo "$RPM_JSON" | jq -r '.deployments[0]["requested-local-packages"][]?' |
        grep -q '^intel-ish-firmware'; then
        sudo rpm-ostree install ./files/intel-ish-firmware-0.1.rpm
        echo "installed intel-ish-firmware"
        echo "reboot required"
        RPM_JSON="$(rpm-ostree status --json)"
    fi
fi

HAS_FFMPEG="$(echo "$RPM_JSON" | jq -r '
  .deployments[0]["requested-packages"][]?,
  .deployments[0]["packages"][]?
' | grep -x 'ffmpeg' || true)"

if [[ -z "$HAS_FFMPEG" ]]; then
    sudo rpm-ostree override remove \
        fdk-aac-free \
        libavcodec-free \
        libavdevice-free \
        libavfilter-free \
        libavformat-free \
        libavutil-free \
        libpostproc-free \
        libswresample-free \
        libswscale-free \
        ffmpeg-free \
        --install ffmpeg

    echo "installed full ffmpeg"
    echo "reboot required"
fi

if ! flatpak remotes --columns=name | grep -qx flathub; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "enabled flathub"
fi

REQUIRED_FLATHUB=(
    org.gimp.GIMP
    org.jellyfin.JellyfinDesktop
    com.mikrotik.WinBox
    io.github.ungoogled_software.ungoogled_chromium
    com.valvesoftware.Steam
)

mapfile -t REQUIRED_FLATHUB < <(printf '%s\n' "${REQUIRED_FLATHUB[@]}" | sort -u)
mapfile -t CURRENT_FLATHUB < <(flatpak list --app --columns=application | tail -n +1 | sort -u)
mapfile -t TO_INSTALL_FLATHUB < <(comm -23 <(printf '%s\n' "${REQUIRED_FLATHUB[@]}") <(printf '%s\n' "${CURRENT_FLATHUB[@]}"))
mapfile -t TO_REMOVE_FLATHUB < <(comm -13 <(printf '%s\n' "${REQUIRED_FLATHUB[@]}") <(printf '%s\n' "${CURRENT_FLATHUB[@]}"))

if [[ "${#TO_REMOVE_FLATHUB[@]}" -gt 0 || "${#TO_INSTALL_FLATHUB[@]}" -gt 0 ]]; then
    matching=$(comm -12 <(printf '%s\n' "${REQUIRED_FLATHUB[@]}") <(printf '%s\n' "${CURRENT_FLATHUB[@]}") | wc -l)
    echo "Packages already matching: $matching"
    echo "Total required: ${#REQUIRED_FLATHUB[@]}"
    echo "Total currently layered: ${#CURRENT_FLATHUB[@]}"
    echo "${TO_INSTALL_FLATHUB[@]}"
    echo "${TO_REMOVE_FLATHUB[@]}"
fi

if [[ "${#TO_REMOVE_FLATHUB[@]}" -gt 0 ]]; then
    echo "Uninstalling extra apps: ${TO_REMOVE_FLATHUB[*]}"
    flatpak uninstall -y "${TO_REMOVE_FLATHUB[@]}"
fi

if [[ "${#TO_INSTALL_FLATHUB[@]}" -gt 0 ]]; then
    echo "Installing missing apps: ${TO_INSTALL_FLATHUB[*]}"
    flatpak install -y flathub "${TO_INSTALL_FLATHUB[@]}"
fi

if [[ ! -d "$HOME/.local/share/themes/catppuccin-latte-green-standard+default" || ! -d "$HOME/.local/share/themes/catppuccin-mocha-green-standard+default" ]]; then
    echo "Installing Catppuccin GTK themes"

    mkdir -p "$HOME/.local/share/themes"

    download_from_github "https://api.github.com/repos/catppuccin/gtk/releases/latest" "catppuccin-latte-green-.*zip"
    unzip -o "catppuccin-latte-green-standard%2Bdefault.zip" -d "$HOME/.local/share/themes/"
    rm -f "catppuccin-latte-green-standard%2Bdefault.zip"

    download_from_github "https://api.github.com/repos/catppuccin/gtk/releases/latest" "catppuccin-mocha-green-.*zip"
    unzip -o "catppuccin-mocha-green-standard%2Bdefault.zip" -d "$HOME/.local/share/themes/"
    rm -f "catppuccin-mocha-green-standard%2Bdefault.zip"

    sudo flatpak override --filesystem=xdg-data/themes

    echo "Catppuccin themes installed"
fi

if [[ ! -d "$FONT_BASE/FiraCode" ]]; then
    echo "installing FiraCode Nerd Font"
    download_from_github "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" "*FiraCode\.zip"

    mkdir -p "$FONT_BASE/FiraCode"
    unzip -o FiraCode.zip -d "$FONT_BASE/FiraCode"
    rm -f FiraCode.zip
fi

if [[ ! -d "$FONT_BASE/AdwaitaMono" ]]; then
    echo "installing AdwaitaMono Nerd Font"
    download_from_github "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" "*AdwaitaMono\.zip"

    mkdir -p "$FONT_BASE/AdwaitaMono"
    unzip -o AdwaitaMono.zip -d "$FONT_BASE/AdwaitaMono"
    rm -f AdwaitaMono.zip
fi

if command -v tailscale >/dev/null 2>&1; then
    enable_service tailscaled
fi

if command -v syncthing >/dev/null 2>&1; then
    enable_service syncthing@c3r5b8
fi

if command -v fish >/dev/null 2>&1; then
    FISH_PATH="$(command -v fish)"
    CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

    if [[ "$CURRENT_SHELL" != "$FISH_PATH" ]]; then
        sudo chsh -s "$FISH_PATH" "$USER"
        echo "changed shell to fish for user $USER"
    fi
fi

normalize_dir "$HOME/Downloads" "$HOME/downloads"
normalize_dir "$HOME/Documents" "$HOME/documents"
normalize_dir "$HOME/Pictures" "$HOME/pictures"
normalize_dir "$HOME/Music" "$HOME/music"
normalize_dir "$HOME/Videos" "$HOME/videos"
normalize_dir "$HOME/Desktop" "$HOME/desktop"
normalize_dir "$HOME/Templates" "$HOME/templates"
normalize_dir "$HOME/Public" "$HOME/public"
stow --target="$HOME" configs
xdg-user-dirs-update
download_wallpaper "element" "https://www.mediafire.com/file/lfyhoee4mihie1b/Element.zip/file"
