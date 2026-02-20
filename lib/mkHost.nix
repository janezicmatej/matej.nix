{
  nixpkgs,
  overlays,
  inputs,
}:

name:
{
  system,
  users ? [ ],
}:

let
  hostConfig = ../hosts/${name}/configuration.nix;
  hostHWConfig = ../hosts/${name}/hardware-configuration.nix;

  userHMConfigs = nixpkgs.lib.genAttrs users (
    user: import ../users/${user}/home-manager.nix { inherit inputs; }
  );

  gib_in_bytes = 1073741824;
in

nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [

    {
      nix.settings = {
        download-buffer-size = 1 * gib_in_bytes;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    }

    { nixpkgs.overlays = overlays; }
    { nixpkgs.config.allowUnfree = true; }

    hostConfig
    hostHWConfig

    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users = userHMConfigs;
      home-manager.extraSpecialArgs = { inherit inputs; };
    }

  ];
  specialArgs = { inherit inputs; };
}
