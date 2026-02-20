{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    yubikey = {
      enable = lib.mkEnableOption "enable yubikey module";
    };
  };

  config = lib.mkIf config.yubikey.enable {
    environment.systemPackages = with pkgs; [
      yubikey-personalization
      yubikey-manager
    ];

    services.pcscd.enable = true;
  };
}
