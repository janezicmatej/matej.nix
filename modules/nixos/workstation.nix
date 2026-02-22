{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    workstation = {
      enable = lib.mkEnableOption "workstation utilities";
    };
  };

  config = lib.mkIf config.workstation.enable {
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
