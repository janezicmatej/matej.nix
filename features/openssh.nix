{
  nixos =
    { lib, config, ... }:
    {
      options = {
        openssh.port = lib.mkOption {
          type = lib.types.port;
          default = 22;
        };
      };

      config = {
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
    };
}
