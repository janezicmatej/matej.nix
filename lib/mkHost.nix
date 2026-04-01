{
  nixpkgs,
  overlays,
  inputs,
}:

name:
{
  system,
  user ? null,
  features ? [ ],
}:

let
  inherit (nixpkgs) lib;
  hasUser = user != null;

  # path helpers
  featurePath =
    f:
    let
      file = ../features/${f}.nix;
      dir = ../features/${f};
    in
    if builtins.pathExists file then file else dir;
  userFeaturePath = u: ../features/user-${u}.nix;
  hostConfig = ../hosts/${name}/configuration.nix;
  hostHWConfig = ../hosts/${name}/hardware-configuration.nix;

  # load feature with path check
  loadFeature =
    f:
    assert
      builtins.pathExists (featurePath f)
      || throw "feature '${f}' not found at ${toString (featurePath f)}";
    import (featurePath f);

  loadedFeatures = map loadFeature features;

  # load user feature with path check
  userFeature =
    if hasUser then
      assert
        builtins.pathExists (userFeaturePath user)
        || throw "user feature 'user-${user}' not found at ${toString (userFeaturePath user)}";
      import (userFeaturePath user)
    else
      null;

  allFeatures = loadedFeatures ++ lib.optional (userFeature != null) userFeature;

  # extract keys from user feature for specialArgs
  userKeys = if userFeature != null then (userFeature.keys or { }) else { };

  # collect nixos and home modules from all features
  nixosMods = map (f: f.nixos) (builtins.filter (f: f ? nixos) allFeatures);
  homeMods = map (f: f.home) (builtins.filter (f: f ? home) allFeatures);
in
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../nix.nix
    inputs.sops-nix.nixosModules.sops

    { nixpkgs.overlays = overlays; }
    { nixpkgs.config.allowUnfree = true; }
    { networking.hostName = name; }

    hostConfig
  ]
  ++ lib.optional (builtins.pathExists hostHWConfig) hostHWConfig
  ++ nixosMods
  ++ lib.optionals hasUser [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.${user}.imports = homeMods;
      home-manager.extraSpecialArgs = { inherit inputs; };
    }
  ];
  specialArgs = {
    inherit inputs userKeys user;
  };
}
