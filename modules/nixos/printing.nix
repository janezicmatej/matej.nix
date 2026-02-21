{
  lib,
  config,
  ...
}:
{
  options = {
    printing = {
      enable = lib.mkEnableOption "CUPS printing with Avahi discovery";
    };
  };

  config = lib.mkIf config.printing.enable {
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
