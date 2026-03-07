{
  lib,
  config,
  ...
}:
{
  options = {
    profiles.base.enable = lib.mkEnableOption "base profile for all machines";
  };

  config = lib.mkIf config.profiles.base.enable {
    openssh.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
    localisation.enable = lib.mkDefault true;
    gnupg.enable = lib.mkDefault true;
  };
}
