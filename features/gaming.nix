{
  nixos =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.gaming;
    in
    {
      options.features.gaming.enable = lib.mkEnableOption "gaming";

      config = lib.mkIf cfg.enable {
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
        };

        environment.systemPackages = [ pkgs.prismlauncher ];
      };
    };
}
