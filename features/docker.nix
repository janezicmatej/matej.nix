{
  nixos =
    { config, lib, user, ... }:
    let
      cfg = config.features.docker;
    in
    {
      options.features.docker.enable = lib.mkEnableOption "docker";

      config = lib.mkIf cfg.enable {
        virtualisation.docker = {
          enable = true;
          logDriver = "json-file";
        };

        users.users.${user}.extraGroups = [ "docker" ];
      };
    };
}
