{ inputs, ... }:

{
  flake.overlays.default =
    _: prev:
    let
      pkgs-stable = import inputs.nixpkgs-stable {
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
    };
}
