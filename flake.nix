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

    flake-utils.url = "github:numtide/flake-utils";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    assets = {
      url = "git+https://git.janezic.dev/janezicmatej/assets.git";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-utils,
      nixos-generators,
      ...
    }:

    let
      my-lib = import ./lib { lib = nixpkgs.lib; };

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

      # nix build .#iso
      # dd bs=4M if=result/iso/my-nixos-live.iso of=/dev/sdX status=progress oflag=sync
      live-iso = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "install-iso";
        specialArgs = { inherit inputs; };
        modules = [ ./iso.nix ];
      };

      nixosConfigurations = {
        matej-nixos = mkHost "matej-nixos" {
          system = "x86_64-linux";
          users = [ "matej" ];
        };
        matej-tower = mkHost "matej-tower" {
          system = "x86_64-linux";
          users = [ "matej" ];
        };

      };

      nixosModules = import ./modules/nixos {
        inherit my-lib;
        lib = nixpkgs.lib;
      } { };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = import ./packages {
          inherit my-lib;
          lib = nixpkgs.lib;
        } (inputs // { inherit system; });

        formatter = pkgs.nixfmt-tree;

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.pre-commit ];
        };
      }
    );
}
