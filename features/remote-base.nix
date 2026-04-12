{
  nixos =
    { config, lib, user, ... }:
    let
      cfg = config.features.remote-base;
    in
    {
      options.features.remote-base.enable = lib.mkEnableOption "remote-base";

      config = lib.mkIf cfg.enable {
        sops.secrets.user-password = {
          sopsFile = ../secrets/common.yaml;
          neededForUsers = true;
        };

        users.mutableUsers = false;
        users.users.${user}.hashedPasswordFile = config.sops.secrets.user-password.path;
      };
    };
}
