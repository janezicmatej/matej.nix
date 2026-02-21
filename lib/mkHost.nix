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
  hasHWConfig = builtins.pathExists hostHWConfig;

  userHMConfigs = nixpkgs.lib.genAttrs users (
    user: import ../users/${user}/home-manager.nix { inherit inputs; }
  );

in
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../nix.nix

    { nixpkgs.overlays = overlays; }
    { nixpkgs.config.allowUnfree = true; }

    hostConfig
  ]
  ++ nixpkgs.lib.optional hasHWConfig hostHWConfig
  ++ [
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
