# Fedora Sericea setup

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
  - Import config in stylus [Catppuccin Userstyles Customizer](https://catppuccin-userstyles-customizer.uncenter.dev)
- Setup telegram
  - Log in
  - Install themes:
    - [Dark](https://t.me/addtheme/ctp_mocha)
    - [Light](https://t.me/addtheme/ctp_latte)
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
