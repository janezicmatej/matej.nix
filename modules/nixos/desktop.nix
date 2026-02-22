{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    desktop = {
      enable = lib.mkEnableOption "base desktop environment";
    };
  };

  config = lib.mkIf config.desktop.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    security.polkit.enable = true;

    services.dbus.enable = true;

    services.playerctld.enable = true;

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    fonts.packages = with pkgs; [
      font-awesome
      nerd-fonts.jetbrains-mono
      maple-mono.NF
    ];
  };
}
