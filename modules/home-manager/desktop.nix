{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options = {
    desktop.enable = lib.mkEnableOption "desktop gui applications";
  };

  config = lib.mkIf config.desktop.enable {
    home.packages = with pkgs; [
      ghostty
      google-chrome
      zathura
      pavucontrol
      bolt-launcher
      libnotify
      bibata-cursors
      vesktop
      rocketchat-desktop
      telegram-desktop
      slack
      jellyfin-media-player
      cider-2
      protonmail-bridge
      ledger-live-desktop
    ];

    services.dunst.enable = true;

    home.file.".assets".source = inputs.assets;
  };
}
