#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

trap 'die "command failed: $BASH_COMMAND (line $LINENO)"' ERR

die() {
    echo "ERROR: $*" >&2
    exit 1
}

target_hostname() {
    local hostname="${1:-}"

    if [[ -n "$hostname" ]]; then
        echo "$hostname"
        return
    fi

    [[ -f /etc/hostname ]] || die "hostname not provided and /etc/hostname does not exist"
    hostname="$(</etc/hostname)"
    hostname="${hostname//$'\n'/}"
    [[ -n "$hostname" ]] || die "/etc/hostname is empty"
    echo "$hostname"
}
enable_service() {
    if ! systemctl is-enabled --quiet "$1"; then
        sudo systemctl enable --now "$1"
        echo "enabled and started $1"
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

    url="$(curl -fsSL "$api" |
        jq -r ".assets[].browser_download_url | select(test(\"$regex\"))" |
        head -n1)"

    [[ -n "$url" ]] || die "No GitHub asset matched: $regex"

    curl -LO "$url"
}

add_repo() {
    if [[ ! -f "/etc/yum.repos.d/$1" ]]; then
        sudo curl -fsSL \
            "$2" \
            -o "/etc/yum.repos.d/$1"
        echo "added $1 repo"
    fi
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

TARGET_HOSTNAME=$(target_hostname "$@")
FEDORA_VER="$(rpm -E %fedora)"
RPM_JSON="$(rpm-ostree status --json)"
INSTALLED_FLATPAKS="$(flatpak list --app --columns=application)"
DOTFILES="$HOME/dev/dotfiles/configs"

set_file "/etc/sudoers.d/00_c3r5b8" "c3r5b8 ALL=(ALL:ALL) NOPASSWD: ALL" "0440"
set_file "/etc/hostname" "$TARGET_HOSTNAME" 0644

enable_service sshd

if ! echo "$RPM_JSON" | jq -r '
    .deployments[0]["requested-local-packages"][]?,
    .deployments[0]["requested-packages"][]?
' | grep -q '^rpmfusion-'; then
    sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"${FEDORA_VER}".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"${FEDORA_VER}".noarch.rpm
    echo "installed rpmfusion"
    echo "reboot required"
    exit 1
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
    sudo cp ./configs/cider.repo /etc/yum.repos.d/cider.repo
    echo "added cider repo"
fi

add_repo tailscale.repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo
add_repo atim-starship-fedora-"${FEDORA_VER}".repo https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora-"${FEDORA_VER}"/atim-starship-fedora-"${FEDORA_VER}".repo
add_repo lihaohong-yazi-fedora-"${FEDORA_VER}".repo https://copr.fedorainfracloud.org/coprs/lihaohong/yazi/repo/fedora-"${FEDORA_VER}"/lihaohong-yazi-fedora-"${FEDORA_VER}".repo
add_repo peterwu-rendezvous-fedora-"${FEDORA_VER}".repo https://copr.fedorainfracloud.org/coprs/peterwu/rendezvous/repo/fedora-"${FEDORA_VER}"/peterwu-rendezvous-fedora-"${FEDORA_VER}".repo

REQUIRED_PACKAGES=("gstreamer1-plugins-bad-free-extras" "gstreamer1-plugins-bad-freeworld" "gstreamer1-plugins-ugly" "gstreamer1-vaapi" "age" "android-tools" "bat" "bibata-cursor-themes" "btop" "Cider" "clang" "fastfetch" "fd-find" "fish" "fzf" "gcc" "git" "go" "gparted" "inkscape" "iperf3" "libreoffice" "make" "neovim" "nmap" "nvtop" "nodejs" "nodejs-npm" "onefetch" "p7zip" "qbittorrent" "rclone" "ripgrep" "krita" "starship" "steam" "syncthing" "tailscale" "telegram-desktop" "thunderbird" "tokei" "wireshark" "xxd" "zoxide" "yazi" "gnome-tweaks")

if [[ "$TARGET_HOSTNAME" == "antares" || "$TARGET_HOSTNAME" == "shaula" ]]; then
    REQUIRED_PACKAGES+=("intel-media-driver" "igt-gpu-tools")
fi

if [[ "$TARGET_HOSTNAME" == "acrab" ]]; then
    REQUIRED_PACKAGES+=("mesa-vdpau-drivers-freeworld")
    if ! echo "$RPM_JSON" | jq -r '.deployments[0]["requested-base-removals"][]?' | grep -q '^mesa-va-drivers'; then
        sudo rpm-ostree override remove mesa-va-drivers --install mesa-va-drivers-freeworld
        RPM_JSON="$(rpm-ostree status --json)"
    fi
fi

INSTALLED_PACKAGES="$(echo "$RPM_JSON" | jq -r '
  .deployments[0]["requested-packages"][]?,
  .deployments[0]["packages"][]?')"

MISSING_PACKAGES=()
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! grep -qx "$pkg" <<<"$INSTALLED_PACKAGES"; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

if [[ "${#MISSING_PACKAGES[@]}" -gt 0 ]]; then
    echo "Installing missing packages: ${MISSING_PACKAGES[*]}"
    sudo rpm-ostree install "${MISSING_PACKAGES[@]}"
    echo "reboot required"
    RPM_JSON="$(rpm-ostree status --json)"
fi

if [[ "$TARGET_HOSTNAME" == "shaula" ]]; then
    INITRAMFS_ENABLED="$(echo "$RPM_JSON" | jq -r '.deployments[0]["regenerate-initramfs"]')"
    if [[ "$INITRAMFS_ENABLED" != "true" ]]; then
        sudo rpm-ostree initramfs --enable
        echo "enabled initramfs regeneration"
        echo "reboot required"
    fi
    if ! echo "$RPM_JSON" | jq -r '.deployments[0]["requested-local-packages"][]?' |
        grep -q '^intel-ish-firmware'; then
        sudo rpm-ostree install ./intel-ish-firmware-0.1.rpm
        echo "installed intel-ish-firmware"
        echo "reboot required"
        RPM_JSON="$(rpm-ostree status --json)"
    fi
    dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-timeout 330
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
    RPM_JSON="$(rpm-ostree status --json)"
fi

if ! flatpak remotes --columns=name | grep -qx flathub; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "enabled flathub"
fi

install_flatpak org.gimp.GIMP
install_flatpak org.jellyfin.JellyfinDesktop
install_flatpak com.mikrotik.WinBox
install_flatpak io.github.ungoogled_software.ungoogled_chromium

if [[ ! -d "$HOME/.local/share/themes/adw-gtk3" ]]; then
    echo "installing adw-gtk3 theme"

    download_from_github "https://api.github.com/repos/lassekongo83/adw-gtk3/releases/latest" "*\.tar\.xz"

    mkdir -p "$HOME/.local/share/themes"

    tar -xf adw-gtk3v*.tar.xz -C "$HOME/.local/share/themes/"
    rm -f adw-gtk3v*.tar.xz
    sudo flatpak override --filesystem=xdg-data/themes
    sudo flatpak mask org.gtk.Gtk3theme.adw-gtk3
    sudo flatpak mask org.gtk.Gtk3theme.adw-gtk3-dark
fi

FONT_BASE="$HOME/.local/share/fonts"

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

if command -v fish >/dev/null 2>&1; then
    FISH_PATH="$(command -v fish)"
    CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

    if [[ "$CURRENT_SHELL" != "$FISH_PATH" ]]; then
        sudo chsh -s "$FISH_PATH" "$USER"
        echo "changed shell to fish for user $USER"
    fi
fi

EXTENSIONS=(
    "AlphabeticalAppGrid@stuarthayhurst"
    "blur-my-shell@aunetx"
    "gsconnect@andyholmes.github.io"
    "panel-corners@aunetx"
    "rounded-window-corners@fxgn"
    "unblank@sun.wxg@gmail.com"
    "forge@jmmaranan.com"
)

INSTALLED_EXTENSIONS="$(gnome-extensions list)"

for EXT in "${EXTENSIONS[@]}"; do
    if ! grep -qx "$EXT" <<<"$INSTALLED_EXTENSIONS"; then
        echo "Installing GNOME extension: $EXT"

        gdbus call --session \
            --dest org.gnome.Shell.Extensions \
            --object-path /org/gnome/Shell/Extensions \
            --method org.gnome.Shell.Extensions.InstallRemoteExtension \
            "$EXT" \
            >/dev/null
    fi
done

FIREFOX_THEME_DIR="$HOME/.mozilla/firefox-gnome-theme"

if [[ ! -d "$FIREFOX_THEME_DIR" ]]; then
    echo "Installing firefox-gnome-theme"

    curl -fsSL \
        https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh |
        bash
    mkdir -p "$FIREFOX_THEME_DIR"
fi

normalize_dir "$HOME/Downloads" "$HOME/downloads"
normalize_dir "$HOME/Documents" "$HOME/documents"
normalize_dir "$HOME/Pictures" "$HOME/pictures"
normalize_dir "$HOME/Music" "$HOME/music"
normalize_dir "$HOME/Videos" "$HOME/videos"
normalize_dir "$HOME/Desktop" "$HOME/desktop"
normalize_dir "$HOME/Templates" "$HOME/templates"
normalize_dir "$HOME/Public" "$HOME/public"
create_link "$DOTFILES/user-dirs.dirs" "$HOME/.config/user-dirs.dirs"
xdg-user-dirs-update

download_wallpaper "element" "https://www.mediafire.com/file/lfyhoee4mihie1b/Element.zip/file"

dconf load / <./configs/gnome.dconf

create_link "$DOTFILES/nvim" "$HOME/.config/nvim"
create_link "$DOTFILES/config.fish" "$HOME/.config/fish/config.fish"
create_link "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"
create_link "$DOTFILES/gtk-3.0.css" "$HOME/.config/gtk-3.0/gtk.css"
create_link "$DOTFILES/gtk-4.0.css" "$HOME/.config/gtk-4.0/gtk.css"
create_link "$DOTFILES/forge.css" "$HOME/.config/forge/stylesheet/forge/stylesheet.css"
create_link "$DOTFILES/gitconfig" "$HOME/.gitconfig"
