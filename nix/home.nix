{ config, pkgs, lib, critPkg, herdrPkg, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in
{
  # home.username / home.homeDirectory are injected from flake.nix

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Common
    git
    neovim
    ghq
    tmux
    ripgrep   # telescope live_grep
    fd        # telescope find_files
    fzf       # fuzzy finder (Ctrl+T / Ctrl+R / Alt+C)
    marp-cli  # markdown presentation converter (used by marp.nvim)
    critPkg   # local-first code review UI for AI agents
    herdrPkg  # terminal workspace manager for AI coding agents
  ]
  ++ lib.optionals pkgs.stdenv.isDarwin [
    # Add macOS-only packages here
  ]
  ++ lib.optionals pkgs.stdenv.isLinux [
    # Add Linux-only packages here
  ];

  # Wire ~/dotfiles/config/* → ~/.config/* via out-of-store symlinks.
  # mkOutOfStoreSymlink points directly at dotfiles instead of going through
  # the nix store, so edits take effect immediately (no home-manager switch).
  xdg.configFile = {
    "git".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/git";
    "tmux".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/tmux";
    "nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/nvim";
    # herdr writes logs/sockets/session state into ~/.config/herdr at runtime,
    # so link only config.toml instead of the whole directory.
    "herdr/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/herdr/config.toml";
  };

  # Claude Code looks for skills under ~/.claude/skills (not under XDG).
  # zshrc is symlinked here too; ~/.zshrc.local is left untracked for per-host overrides.
  home.file = {
    ".claude/skills".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/claude/skills";
    ".zshrc".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/zsh/zshrc";
  };

  programs.home-manager.enable = true;
}
