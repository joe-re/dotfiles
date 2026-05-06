.PHONY: help install home-switch home-news sys-switch sys-dry sys-status sys-logs sys-uninstall

.DEFAULT_GOAL := help

NIX_FLAGS := --extra-experimental-features 'nix-command flakes'

# Pick the flake entry by `hostname -s`.
# Override with `make home-switch HOST=macbook` to target another host.
HOST ?= $(shell hostname -s)

help:
	@echo "Targets:"
	@echo "  install        Install Nix (Determinate Systems installer)"
	@echo "  home-switch    Apply home-manager (HOST=$(HOST))"
	@echo "  home-news      Show home-manager news"
	@echo "  sys-switch     Apply system-manager (sshd)"
	@echo "  sys-dry        Dry-run system-manager"
	@echo "  sys-status     Show sshd-system-manager status"
	@echo "  sys-logs       Tail sshd-system-manager logs"
	@echo "  sys-uninstall  Deactivate system-manager"

# === Install Nix ===
install:
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

# === home-manager (user-scope: packages + dotfiles) ===
home-switch:
	nix run $(NIX_FLAGS) github:nix-community/home-manager -- \
	  switch --flake '.#$(HOST)' -b backup

home-news:
	nix run $(NIX_FLAGS) github:nix-community/home-manager -- news --flake '.#$(HOST)'

# === system-manager (system-scope: sshd) ===
sys-switch:
	sudo nix run $(NIX_FLAGS) github:numtide/system-manager -- \
	  switch --flake '.#default'

sys-dry:
	sudo nix run $(NIX_FLAGS) github:numtide/system-manager -- \
	  switch --flake '.#default' --dry-run

sys-status:
	systemctl status sshd-system-manager --no-pager
	@echo "---"
	ss -tlnp | grep :22 || true

sys-logs:
	journalctl -u sshd-system-manager -n 50 --no-pager

sys-uninstall:
	sudo nix run $(NIX_FLAGS) github:numtide/system-manager -- deactivate
