{ inputs, ... }:

{
  flake.overlays.default = final: _prev: {
    inherit (inputs.nixpkgs-stable.legacyPackages.${final.stdenv.hostPlatform.system}) mcp-nixos;
  };
}
