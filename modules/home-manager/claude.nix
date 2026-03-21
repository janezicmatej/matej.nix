{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  packages = inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options = {
    claude = {
      enable = lib.mkEnableOption "claude code";
      package = lib.mkPackageOption pkgs "claude-code" { };
    };
  };

  config = lib.mkIf config.claude.enable {
    home.packages = [
      config.claude.package
      pkgs.mcp-nixos
    ];
  };
}
