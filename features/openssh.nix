{
  nixos =
    { lib, config, ... }:
    let
      cfg = config.features.openssh;
    in
    {
      options.features.openssh = {
        enable = lib.mkEnableOption "openssh";

        port = lib.mkOption {
          type = lib.types.port;
          default = 22;
        };
      };

      config = lib.mkIf cfg.enable {
        services.openssh = {
          enable = true;
          ports = [ cfg.port ];
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
