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
    dev.enable = lib.mkEnableOption "development tools";
  };

  config = lib.mkIf config.dev.enable {
    home.packages = [
      pkgs.git
      packages.git-linearize
      packages.ggman
      pkgs.go
      pkgs.python3
      pkgs.mdbook
      pkgs.marksman
      pkgs.mdformat
      pkgs.google-cloud-sdk
      pkgs.google-cloud-sql-proxy
      packages.ahab
      pkgs.just
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
