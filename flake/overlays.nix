{ inputs, ... }:

{
  flake.overlays.default = final: _prev: {
    inherit (inputs.nixpkgs-stable.legacyPackages.${final.stdenv.hostPlatform.system})
      mcp-nixos
      # v4.16.0 not in supported versions yet
      rocketchat-desktop
      ;
  };
}
