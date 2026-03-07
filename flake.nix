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
    # nvim = {
    #   url = "git+https://git.janezic.dev/janezicmatej/nvim.git?ref=rewrite";
    #   flake = false;
    # };

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
    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-utils,
      ...
    }:

    let
      my-lib = import ./lib { inherit (nixpkgs) lib; };

      overlays = [ ];

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
        matej-nixos = mkHost "matej-nixos" {
          system = "x86_64-linux";
          user = "matej";
        };
        matej-tower = mkHost "matej-tower" {
          system = "x86_64-linux";
          user = "matej";
        };

        # nixos-rebuild build-image --image-variant install-iso --flake .#live-iso
        live-iso = mkHost "live-iso" {
          system = "x86_64-linux";
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
          ];
        };
      }
    );
}
