{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.workstation;
in
{
  options = {
    workstation = {
      enable = lib.mkEnableOption "workstation utilities";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      logDriver = "json-file";
    };

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };

    environment.systemPackages = with pkgs; [
      smartmontools
    ];
  };
}
