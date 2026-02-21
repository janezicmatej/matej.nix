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
    # Audio
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Bluetooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    # Security
    security.polkit.enable = true;

    # D-Bus
    services.dbus.enable = true;

    # Player control
    services.playerctld.enable = true;

    # XDG Portals
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    # Fonts
    fonts.packages = with pkgs; [
      font-awesome
      nerd-fonts.jetbrains-mono
      maple-mono.NF
    ];
  };
}
