# Fedora silverblue setup

## Seup steps

```bash
git clone https://github.com/c3r5b8/dotfiles.git
cd dotfiles
bash main.sh
```

- `sudo tailscale up`
- Setup firefox
  - Log In
  - Setup DarkReader
  - Firefox settings
  - Setup Bitwarden
  - Add css to vimium
- Setup telegram
  - Log in
  - Install themes:
    - [Dark green](https://t.me/addtheme/Gb0JMMgztJLeWF7Q)
    - [Light green](https://t.me/addtheme/dH0F0uMM7vifFutW)
  - Enable qt feame and hw video decoding, disable "Draw attention to the window"
- Setup syncthing
  - [local](http://localhost:8384/), [sargas](https://syncthing.c3r5b8.dev/)

Setup ssh keys:

```bash
mkdir -p ~/.ssh
nano ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
```
