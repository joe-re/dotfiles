{
  description = "Nix config — home-manager (small start) + system-manager (sshd)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, system-manager, ... }:
    let
      mkHome = { system, username, homeDirectory }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [
            ./home.nix
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ];
        };
    in
    {
      # One entry per host. Entry names should match `hostname -s`;
      # the Makefile picks the matching entry automatically.
      homeConfigurations = {
        # Raspberry Pi 5 (Ubuntu)
        "masatonoguchi-raspi5" = mkHome {
          system = "aarch64-linux";
          username = "masatonoguchi";
          homeDirectory = "/home/masatonoguchi";
        };

        # macOS — adjust entry name / system / username / homeDirectory per machine.
        # system: "aarch64-darwin" for Apple Silicon, "x86_64-darwin" for Intel.
        "macbook" = mkHome {
          system = "aarch64-darwin";
          username = "masatonoguchi";
          homeDirectory = "/Users/masatonoguchi";
        };
      };

      # system-manager: sshd (Linux only)
      systemConfigs.default = system-manager.lib.makeSystemConfig {
        modules = [ ./modules/ssh.nix ];
      };
    };
}
