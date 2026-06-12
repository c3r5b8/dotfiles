# Fedora Kinoite setup

## Seup steps

After installation and updating:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- init --apply c3r5b8
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
  - Enable qt feame and hw video decoding, disable "Draw attention to the window"

Setup ssh keys:

```bash
mkdir -p ~/.ssh
nano ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
```
