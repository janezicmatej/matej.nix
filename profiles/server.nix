{
  lib,
  config,
  ...
}:
{
  options = {
    profiles.server.enable = lib.mkEnableOption "headless server profile";
  };

  config = lib.mkIf config.profiles.server.enable {
    profiles.base.enable = lib.mkDefault true;
    workstation.enable = lib.mkDefault true;
  };
}
