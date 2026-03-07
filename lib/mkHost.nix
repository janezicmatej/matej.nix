{
  nixpkgs,
  overlays,
  inputs,
}:

name:
{
  system,
  user ? null,
}:

let
  hostConfig = ../hosts/${name}/configuration.nix;
  hostHWConfig = ../hosts/${name}/hardware-configuration.nix;
  hasHWConfig = builtins.pathExists hostHWConfig;
  hasUser = user != null;

  userKeys = if hasUser then import ../users/${user}/keys.nix else { };

  # auto-import all nixos modules and profiles
  nixosModuleList = builtins.attrValues inputs.self.nixosModules;
  nixosProfileList = builtins.attrValues inputs.self.nixosProfiles;

  # auto-import all home-manager modules
  hmModuleList = builtins.attrValues inputs.self.homeManagerModules;

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
  ++ nixosModuleList
  ++ nixosProfileList
  ++ nixpkgs.lib.optional (
    hasUser && builtins.pathExists ../users/${user}/nixos.nix
  ) ../users/${user}/nixos.nix
  ++ [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users = nixpkgs.lib.mkIf hasUser {
        ${user} = import ../users/${user}/home-manager.nix;
      };
      home-manager.sharedModules = hmModuleList;
      home-manager.extraSpecialArgs = { inherit inputs; };
    }
  ];
  specialArgs = { inherit inputs userKeys; };
}
