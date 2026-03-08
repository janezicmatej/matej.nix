{
  description = "matej's nix setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    # dotfiles = {
    #   url = "git+https://git.janezic.dev/janezicmatej/.dotfiles.git";
    #   flake = false;
    # };
    nvim = {
      url = "git+https://git.janezic.dev/janezicmatej/nvim.git";
      flake = false;
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    assets = {
      url = "git+https://git.janezic.dev/janezicmatej/assets.git";
      flake = false;
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

  };

  outputs =
    inputs@{
      nixpkgs,
      flake-utils,
      ...
    }:

    let
      my-lib = import ./lib { inherit (nixpkgs) lib; };

      overlays = [
        (
          _: prev:
          let
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit (prev.stdenv.hostPlatform) system;
              inherit (prev) config;
            };
            pkgs-master = import inputs.nixpkgs-master {
              inherit (prev.stdenv.hostPlatform) system;
              inherit (prev) config;
            };
          in
          {
            inherit (pkgs-master) claude-code;
            # TODO:(@janezicmatej) 2026-03-09 error with stable for telegram-desktop
            inherit (pkgs-unstable) telegram-desktop;
          }
        )
      ];

      mkHost = my-lib.mkHost {
        inherit
          nixpkgs
          overlays
          inputs
          ;
      };

    in

    {
      lib = my-lib;

      nixosConfigurations = {
        fw16 = mkHost "fw16" {
          system = "x86_64-linux";
          user = "matej";
        };
        tower = mkHost "tower" {
          system = "x86_64-linux";
          user = "matej";
        };

        # nixos-rebuild build-image --image-variant install-iso --flake .#iso
        iso = mkHost "iso" {
          system = "x86_64-linux";
        };

        ephvm = mkHost "ephvm" {
          system = "x86_64-linux";
          user = "matej";
        };
      };

      nixosModules = import ./modules/nixos {
        inherit my-lib;
        inherit (nixpkgs) lib;
      } { };

      homeManagerModules = import ./modules/home-manager {
        inherit my-lib;
        inherit (nixpkgs) lib;
      } { };

      nixosProfiles = import ./profiles {
        inherit my-lib;
        inherit (nixpkgs) lib;
      } { };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages =
          import ./packages
            {
              inherit my-lib;
              inherit (nixpkgs) lib;
            }
            {
              pkgs = nixpkgs.legacyPackages.${system};
              pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
              pkgs-master = inputs.nixpkgs-master.legacyPackages.${system};
            };

        formatter = pkgs.nixfmt-tree;

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.pre-commit
            pkgs.statix
            pkgs.qemu
          ];
        };
      }
    );
}
