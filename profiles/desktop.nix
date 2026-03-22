{
  lib,
  config,
  ...
}:
{
  options = {
    profiles.desktop.enable = lib.mkEnableOption "desktop profile (sway, audio, printing)";
  };

  config = lib.mkIf config.profiles.desktop.enable {
    profiles.base.enable = lib.mkDefault true;
    desktop.enable = lib.mkDefault true;
    sway.enable = lib.mkDefault true;
    greeter.enable = lib.mkDefault true;
    printing.enable = lib.mkDefault true;
    workstation.enable = lib.mkDefault true;
    yubikey.enable = lib.mkDefault true;
    calibre.enable = lib.mkDefault true;
  };
}
