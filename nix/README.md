# nix/

## Setup

### 1. Install Nix

```bash
cd ~/dotfiles/nix
make install
```

After it finishes, open a new shell.

### 2. Apply home-manager

```bash
cd ~/dotfiles/nix
make home-switch
```

On macOS, `hostname -s` often does not match the flake entry name, so pass `HOST` explicitly:

```bash
make home-switch HOST=macbook
```

### 3. Apply system-manager (sshd) — only if needed

If Ubuntu's default `ssh.service` is already bound to :22, stop it first (otherwise `sshd-system-manager` will fail to start):

```bash
sudo systemctl disable --now ssh ssh.socket
```

Then:

```bash
cd ~/dotfiles/nix
make sys-switch
```
