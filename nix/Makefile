.PHONY: help install home-switch home-news sys-switch sys-dry sys-status sys-logs sys-uninstall

.DEFAULT_GOAL := help

# Use absolute path so `sudo` (which drops nix from PATH via secure_path) can find it.
NIX_BIN := /nix/var/nix/profiles/default/bin
NIX := $(NIX_BIN)/nix
NIX_FLAGS := --extra-experimental-features 'nix-command flakes'

# home-manager (and other Nix tools it invokes) re-exec `nix` via PATH lookup,
# so make sure the Nix profile bin is on PATH for every recipe.
export PATH := $(NIX_BIN):$(PATH)

# Pick the flake entry by `hostname -s`.
# Override with `make home-switch HOST=macbook` to target another host.
HOST ?= $(shell hostname -s)

help:
	@echo "Targets:"
	@echo "  install        Install Nix (Determinate Systems installer)"
	@echo "  home-switch    Apply home-manager (HOST=$(HOST))"
	@echo "  home-news      Show home-manager news"
	@echo "  sys-switch     Apply system-manager (sshd)"
	@echo "  sys-dry        Build system-manager profile without activating (dry-run equivalent)"
	@echo "  sys-status     Show sshd-system-manager status"
	@echo "  sys-logs       Tail sshd-system-manager logs"
	@echo "  sys-uninstall  Deactivate system-manager"

# === Install Nix ===
install:
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

# === home-manager (user-scope: packages + dotfiles) ===
# home-manager writes its profile under $XDG_STATE_HOME/nix/profiles on
# multi-user Nix installs; create it up front so the first switch succeeds.
home-switch:
	mkdir -p "$${XDG_STATE_HOME:-$$HOME/.local/state}/nix/profiles"
	$(NIX) run $(NIX_FLAGS) github:nix-community/home-manager -- \
	  switch --flake '.#$(HOST)' -b backup

home-news:
	$(NIX) run $(NIX_FLAGS) github:nix-community/home-manager -- news --flake '.#$(HOST)'

# === system-manager (system-scope: sshd) ===
sys-switch:
	sudo $(NIX) run $(NIX_FLAGS) github:numtide/system-manager -- \
	  switch --flake '.#default'

sys-dry:
	sudo $(NIX) run $(NIX_FLAGS) github:numtide/system-manager -- \
	  build --flake '.#default'

sys-status:
	systemctl status sshd-system-manager --no-pager
	@echo "---"
	ss -tlnp | grep :22 || true

sys-logs:
	journalctl -u sshd-system-manager -n 50 --no-pager

sys-uninstall:
	sudo $(NIX) run $(NIX_FLAGS) github:numtide/system-manager -- deactivate
