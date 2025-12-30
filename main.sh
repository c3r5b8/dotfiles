
#set -Eeuo pipefail
#IFS=$'\n\t'

HOSTNAME_ARG="$1"
if [[ -n "$HOSTNAME_ARG" ]]; then
    TARGET_HOSTNAME="$HOSTNAME_ARG"
elif [[ -f "/etc/hostname" ]]; then
    TARGET_HOSTNAME="$(tr -d '\n' < "/etc/hostname")"
    if [[ -z "$TARGET_HOSTNAME" ]]; then
        echo "ERROR: /etc/hostname is empty"
        exit 1
    fi
else
    echo "ERROR: hostname not provided and /etc/hostname does not exist"
    exit 1
fi

echo "Using hostname: $TARGET_HOSTNAME"


FEDORA_VER="$(rpm -E %fedora)"

REQUIRED="c3r5b8 ALL=(ALL:ALL) NOPASSWD: ALL"
FILE="/etc/sudoers.d/00_c3r5b8"
if [[ "$(sudo cat "$FILE" 2>/dev/null)" != "$REQUIRED" ]]; then
    echo "$REQUIRED" | sudo tee "$FILE" > /dev/null
    sudo chmod 0440 "$FILE"
    echo "created sudoers file"
fi

REQUIRED="$TARGET_HOSTNAME"
FILE="/etc/hostname"
if [[ "$(cat "$FILE" 2>/dev/null)" != "$REQUIRED" ]]; then
    echo "$REQUIRED" | sudo tee "$FILE" > /dev/null
    sudo hostnamectl set-hostname "$REQUIRED"
    echo "created hostname file"
fi

if ! systemctl is-enabled --quiet sshd; then
    sudo systemctl enable --now sshd
    echo "enabled and started sshd"
fi

if ! rpm-ostree status --json | jq -r '
    .deployments[0]["requested-local-packages"][]?,
    .deployments[0]["requested-packages"][]?
' | grep -q '^rpmfusion-'; then
    sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    echo "installed rpmfusion"
    echo "reboot required"
    exit 1
fi

if rpm-ostree status --json | jq -r '.deployments[0].["requested-local-packages"][]' | grep -q rpmfusion; then
    sudo rpm-ostree update \
      --uninstall rpmfusion-free-release \
      --uninstall rpmfusion-nonfree-release \
      --install rpmfusion-free-release \
      --install rpmfusion-nonfree-release
fi

# tailscale
if [[ ! -f "/etc/yum.repos.d/tailscale.repo" ]]; then
    sudo curl -fsSL \
        https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
        -o "/etc/yum.repos.d/tailscale.repo"
    echo "added tailscale repo"
fi

if [[ ! -f "/etc/yum.repos.d/cider.repo" ]]; then
    sudo tee /etc/yum.repos.d/cider.repo << 'EOF'
[cidercollective]
name=Cider Collective Repository
baseurl=https://repo.cider.sh/rpm/RPMS
enabled=1
gpgcheck=1
gpgkey=https://repo.cider.sh/RPM-GPG-KEY
EOF
    echo "added cider repo"
fi

# starship (copr)
if [[ ! -f "/etc/yum.repos.d/atim-starship-fedora-${FEDORA_VER}.repo" ]]; then
    sudo curl -fsSL \
        https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora-${FEDORA_VER}/atim-starship-fedora-${FEDORA_VER}.repo \
        -o "/etc/yum.repos.d/atim-starship-fedora-${FEDORA_VER}.repo"
    echo "added starship copr"
fi

# yazi (copr)
if [[ ! -f "/etc/yum.repos.d/lihaohong-yazi-fedora-${FEDORA_VER}.repo" ]]; then
    sudo curl -fsSL \
        https://copr.fedorainfracloud.org/coprs/lihaohong/yazi/repo/fedora-${FEDORA_VER}/lihaohong-yazi-fedora-${FEDORA_VER}.repo \
        -o "/etc/yum.repos.d/lihaohong-yazi-fedora-${FEDORA_VER}.repo"
    echo "added yazi copr"
fi

# rendezvous (copr)
if [[ ! -f "/etc/yum.repos.d/peterwu-rendezvous-fedora-${FEDORA_VER}.repo" ]]; then
    sudo curl -fsSL \
        https://copr.fedorainfracloud.org/coprs/peterwu/rendezvous/repo/fedora-${FEDORA_VER}/peterwu-rendezvous-fedora-${FEDORA_VER}.repo \
        -o "/etc/yum.repos.d/peterwu-rendezvous-fedora-${FEDORA_VER}.repo"
    echo "added rendezvous copr"
fi

# Build list of required packages depending on hostname
REQUIRED_PACKAGES=("gstreamer1-plugins-bad-free-extras" "gstreamer1-plugins-bad-freeworld" "gstreamer1-plugins-ugly" "gstreamer1-vaapi" "age" "android-tools" "bat" "bibata-cursor-themes" "btop" "Cider" "clang" "fastfetch" "fd-find" "fish" "fzf" "gcc" "git" "go" "gparted" "inkscape" "iperf3" "libreoffice" "make" "neovim" "nmap" "nvtop" "nodejs" "nodejs-npm" "onefetch" "p7zip" "qbittorrent" "rclone" "ripgrep" "krita" "starship" "steam" "syncthing" "tailscale" "telegram-desktop" "thunderbird" "tokei" "wireshark" "xxd" "zoxide" "yazi" "gnome-tweaks")

if [[ "$TARGET_HOSTNAME" == "antares" || "$TARGET_HOSTNAME" == "shaula" ]]; then
    REQUIRED_PACKAGES+=("intel-media-driver" "igt-gpu-tools")
fi

if [[ "$TARGET_HOSTNAME" == "acrab" ]]; then
    REQUIRED_PACKAGES+=("mesa-vdpau-drivers-freeworld")
        if ! echo "$RPM_JSON" | jq -r '.deployments[0]["requested-base-removals"][]?' | grep -q '^mesa-va-drivers'; then
        sudo rpm-ostree override remove mesa-va-drivers --install mesa-va-drivers-freeworld
    fi

fi

# Get installed/layered packages list from current deployment
INSTALLED_PACKAGES="$(rpm-ostree status --json | jq -r '
  .deployments[0]["requested-packages"][]?,
  .deployments[0]["packages"][]?')"

# Compute missing packages
MISSING_PACKAGES=()
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! grep -qx "$pkg" <<< "$INSTALLED_PACKAGES"; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

# Install missing packages in one transaction
if [[ "${#MISSING_PACKAGES[@]}" -gt 0 ]]; then
    echo "Installing missing packages: ${MISSING_PACKAGES[*]}"
    sudo rpm-ostree install "${MISSING_PACKAGES[@]}"
    echo "reboot required"
fi
RPM_JSON="$(rpm-ostree status --json)"

if [[ "$TARGET_HOSTNAME" == "shaula" ]]; then

    INITRAMFS_ENABLED="$(echo "$RPM_JSON" | jq -r '.deployments[0]["regenerate-initramfs"]')"

    if [[ "$INITRAMFS_ENABLED" != "true" ]]; then
        sudo rpm-ostree initramfs --enable
        echo "enabled initramfs regeneration"
        echo "reboot required"
    fi

    # --- local firmware package ---
    if ! echo "$RPM_JSON" | jq -r '.deployments[0]["requested-local-packages"][]?' \
        | grep -q '^intel-ish-firmware'; then
        sudo rpm-ostree install ./intel-ish-firmware-0.1.rpm
        echo "installed intel-ish-firmware"
        echo "reboot required"
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
fi

if ! flatpak remotes --columns=name | grep -qx flathub; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "enabled flathub"
fi

INSTALLED_FLATPAKS="$(flatpak list --app --columns=application)"

if ! grep -qx 'org.gimp.GIMP' <<< "$INSTALLED_FLATPAKS"; then
    flatpak install flathub org.gimp.GIMP -y
    echo "installed GIMP"
fi

if ! grep -qx 'org.jellyfin.JellyfinDesktop' <<< "$INSTALLED_FLATPAKS"; then
    flatpak install flathub org.jellyfin.JellyfinDesktop -y
    echo "installed Jellyfin Desktop"
fi

if ! grep -qx 'com.mikrotik.WinBox' <<< "$INSTALLED_FLATPAKS"; then
    flatpak install flathub com.mikrotik.WinBox -y
    echo "installed WinBox"
fi

if ! grep -qx 'io.github.ungoogled_software.ungoogled_chromium' <<< "$INSTALLED_FLATPAKS"; then
    flatpak install flathub io.github.ungoogled_software.ungoogled_chromium -y
    echo "installed Ungoogled Chromium"
fi

# adw-gtk3 theme
if [[ ! -d "$HOME/.local/share/themes/adw-gtk3" ]]; then
    echo "installing adw-gtk3 theme"

    curl -s https://api.github.com/repos/lassekongo83/adw-gtk3/releases/latest \
      | grep -E 'browser_download_url.*\.tar\.xz' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -O

    mkdir -p "$HOME/.local/share/themes"

    tar -xf adw-gtk3v*.tar.xz -C "$HOME/.local/share/themes/"
    rm -f adw-gtk3v*.tar.xz
    sudo flatpak override --filesystem=xdg-data/themes
    sudo flatpak mask org.gtk.Gtk3theme.adw-gtk3
    sudo flatpak mask org.gtk.Gtk3theme.adw-gtk3-dark
fi

# nerd fonts
FONT_BASE="$HOME/.local/share/fonts"

mkdir -p "$FONT_BASE"

if [[ ! -d "$FONT_BASE/FiraCode" ]]; then
    echo "installing FiraCode Nerd Font"
    curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
      | grep -E 'browser_download_url.*FiraCode\.zip' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -O

    mkdir -p "$FONT_BASE/FiraCode"
    unzip -o FiraCode.zip -d "$FONT_BASE/FiraCode"
    rm -f FiraCode.zip
fi

if [[ ! -d "$FONT_BASE/AdwaitaMono" ]]; then
    echo "installing AdwaitaMono Nerd Font"
    curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
      | grep -E 'browser_download_url.*AdwaitaMono\.zip' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -O

    mkdir -p "$FONT_BASE/AdwaitaMono"
    unzip -o AdwaitaMono.zip -d "$FONT_BASE/AdwaitaMono"
    rm -f AdwaitaMono.zip
fi

if command -v tailscale >/dev/null 2>&1; then
    if ! systemctl is-enabled --quiet tailscaled; then
        sudo systemctl enable --now tailscaled
        echo "enabled and started tailscaled"
    fi
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
    if ! grep -qx "$EXT" <<< "$INSTALLED_EXTENSIONS"; then
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
      https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh \
      | bash
   mkdir -p $FIREFOX_THEME_DIR
fi

USER_DIRS="$HOME/.config/user-dirs.dirs"

if ! grep -q 'XDG_DOWNLOAD_DIR="\$HOME/downloads"' "$USER_DIRS" 2>/dev/null; then
    echo "Normalizing XDG user directories to lowercase"

    [[ -d "$HOME/Downloads"  ]] && mv "$HOME/Downloads"  "$HOME/downloads"  || mkdir -p "$HOME/downloads"
    [[ -d "$HOME/Documents"  ]] && mv "$HOME/Documents"  "$HOME/documents"  || mkdir -p "$HOME/documents"
    [[ -d "$HOME/Pictures"   ]] && mv "$HOME/Pictures"   "$HOME/pictures"   || mkdir -p "$HOME/pictures"
    [[ -d "$HOME/Music"      ]] && mv "$HOME/Music"      "$HOME/music"      || mkdir -p "$HOME/music"
    [[ -d "$HOME/Videos"     ]] && mv "$HOME/Videos"     "$HOME/videos"     || mkdir -p "$HOME/videos"
    [[ -d "$HOME/Desktop"    ]] && mv "$HOME/Desktop"    "$HOME/desktop"    || mkdir -p "$HOME/desktop"
    [[ -d "$HOME/Templates"  ]] && mv "$HOME/Templates"  "$HOME/templates"  || mkdir -p "$HOME/templates"
    [[ -d "$HOME/Public"     ]] && mv "$HOME/Public"     "$HOME/public"     || mkdir -p "$HOME/public"

    mkdir -p "$HOME/.config"

    cat > "$USER_DIRS" << 'EOF'
XDG_DESKTOP_DIR="$HOME/desktop"
XDG_DOWNLOAD_DIR="$HOME/downloads"
XDG_TEMPLATES_DIR="$HOME/templates"
XDG_PUBLICSHARE_DIR="$HOME/public"
XDG_DOCUMENTS_DIR="$HOME/documents"
XDG_MUSIC_DIR="$HOME/music"
XDG_PICTURES_DIR="$HOME/pictures"
XDG_VIDEOS_DIR="$HOME/videos"
EOF

    xdg-user-dirs-update
fi

WALLPAPER_DIR="$HOME/pictures/wallpapers"
MF_URL="https://www.mediafire.com/file/lfyhoee4mihie1b/Element.zip/file"

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    echo "Downloading wallpapers…"

    # create the dir if it doesn't exist
    mkdir -p "$WALLPAPER_DIR"

    # get the real direct download link from MediaFire
    DL_LINK=$(curl -fsSL "$MF_URL" \
        | grep -oE 'https://download[^"]+' \
        | head -n 1)

    if [[ -z "$DL_LINK" ]]; then
        echo "ERROR: Could not resolve MediaFire direct link"
        exit 1
    fi

    # download the zip
    curl -fsSL -o Element.zip "$DL_LINK"

    # unzip into wallpapers dir
    unzip -o Element.zip -d "$WALLPAPER_DIR"

    # move nested files up (if any)
    find "$WALLPAPER_DIR" -mindepth 2 -type f -exec mv {} "$WALLPAPER_DIR/" \;

    # remove any empty leftover dirs
    find "$WALLPAPER_DIR" -mindepth 1 -type d -empty -delete

    # cleanup
    rm -f Element.zip

    echo "Wallpapers installed in $WALLPAPER_DIR"
fi

dconf load / < gnome.dconf

GTK3_DIR="$HOME/.config/gtk-3.0"
GTK4_DIR="$HOME/.config/gtk-4.0"

GTK3_FILE="$GTK3_DIR/gtk.css"
GTK4_FILE="$GTK4_DIR/gtk.css"

read -r -d '' GTK3_CONTENT << 'EOF'
@define-color accent_blue #3584e4;
@define-color accent_teal #2190a4;
@define-color accent_green #3a944a;
@define-color accent_yellow #c88800;
@define-color accent_orange #ed5b00;
@define-color accent_red #e62d42;
@define-color accent_pink #d56199;
@define-color accent_purple #9141ac;
@define-color accent_slate #6f8396;
@define-color accent_bg_color @accent_green;
EOF

GTK4_CONTENT=':root { --accent-bg-color: var(--accent-green); }'

GTK3_CURRENT_HASH="$(sha256sum "$GTK3_FILE" 2>/dev/null | cut -d' ' -f1)"
GTK3_NEW_HASH="$(printf '%s\n' "$GTK3_CONTENT" | sha256sum | cut -d' ' -f1)"

GTK4_CURRENT_HASH="$(sha256sum "$GTK4_FILE" 2>/dev/null | cut -d' ' -f1)"
GTK4_NEW_HASH="$(printf '%s\n' "$GTK4_CONTENT" | sha256sum | cut -d' ' -f1)"

if [[ "$GTK3_CURRENT_HASH" != "$GTK3_NEW_HASH" || "$GTK4_CURRENT_HASH" != "$GTK4_NEW_HASH" ]]; then
    echo "Updating GTK accent CSS"

    mkdir -p "$GTK3_DIR" "$GTK4_DIR"

    printf '%s\n' "$GTK4_CONTENT" > "$GTK4_FILE"
    printf '%s\n' "$GTK3_CONTENT" > "$GTK3_FILE"
fi

FORGE_SRC="forge.css"
FORGE_DIR="$HOME/.config/forge/stylesheet/forge"
FORGE_DST="$FORGE_DIR/stylesheet.css"

if [[ ! -f "$FORGE_SRC" ]]; then
    echo "ERROR: $FORGE_SRC not found"
    exit 1
fi

# Compute hashes
SRC_HASH="$(sha256sum "$FORGE_SRC" | cut -d' ' -f1)"
DST_HASH="$(sha256sum "$FORGE_DST" 2>/dev/null | cut -d' ' -f1)"

if [[ "$SRC_HASH" != "$DST_HASH" ]]; then
    echo "Updating Forge stylesheet"

    mkdir -p "$FORGE_DIR"
    cp "$FORGE_SRC" "$FORGE_DST"
fi

DOTFILES="$HOME/dev/dotfiles"
if ! [[ -L ~/.gitconfig && "$(readlink ~/.gitconfig)" = "$DOTFILES/gitconfig" ]]; then
    rm -rf ~/.gitconfig 2>/dev/null
    ln -sf "$DOTFILES/gitconfig" ~/.gitconfig
    echo "gitconfig -> linked"
fi
