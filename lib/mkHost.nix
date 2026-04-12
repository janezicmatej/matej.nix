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

  # auto-discover all features, excluding user-* and default.nix
  featureDir = builtins.readDir ../features;
  allFeatureNames = lib.pipe featureDir [
    (lib.filterAttrs (
      n: t:
      (t == "regular" && lib.hasSuffix ".nix" n && n != "default.nix" && !lib.hasPrefix "user-" n)
      || (t == "directory" && builtins.pathExists ../features/${n}/default.nix)
    ))
    builtins.attrNames
    (map (n: lib.removeSuffix ".nix" n))
  ];

  # load all features unconditionally
  loadFeature =
    f:
    assert
      builtins.pathExists (featurePath f)
      || throw "feature '${f}' not found at ${toString (featurePath f)}";
    import (featurePath f);

  loadedFeatures = map loadFeature allFeatureNames;

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

  # translate features list to enable flags
  featureEnableModule =
    { lib, ... }:
    {
      config.features = lib.genAttrs features (_: {
        enable = true;
      });
    };
in
nixpkgs.lib.nixosSystem {
  inherit system;
  modules =
    [
      inputs.sops-nix.nixosModules.sops
      inputs.stylix.nixosModules.stylix

      { nixpkgs.overlays = overlays; }
      { nixpkgs.config.allowUnfree = true; }
      { networking.hostName = name; }

      featureEnableModule
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
