{ inputs, ... }:

{
  flake.overlays.default = final: _prev: {
    mcp-nixos = inputs.nixpkgs-stable.legacyPackages.${final.stdenv.hostPlatform.system}.mcp-nixos;
  };
}
