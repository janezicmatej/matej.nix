{ inputs, ... }:

{
  flake.overlays.default =
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
    };
}
