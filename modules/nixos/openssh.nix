{
  lib,
  config,
  ...
}:
{
  options = {
    openssh = {
      enable = lib.mkEnableOption "hardened SSH server";
      port = lib.mkOption {
        type = lib.types.port;
        default = 22;
        description = "SSH server port";
      };
    };
  };

  config = lib.mkIf config.openssh.enable {
    services.openssh = {
      enable = true;
      ports = [ config.openssh.port ];
      settings = {
        PasswordAuthentication = false;
        AllowUsers = null;
        PermitRootLogin = "no";
        StreamLocalBindUnlink = "yes";
      };
    };
  };
}
