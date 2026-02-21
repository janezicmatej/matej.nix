{
  lib,
  config,
  ...
}:
{
  options = {
    gnupg = {
      enable = lib.mkEnableOption "GnuPG agent with SSH support";
    };
  };

  config = lib.mkIf config.gnupg.enable {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableExtraSocket = true;
    };
  };
}
