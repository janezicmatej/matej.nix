{
  nixos =
    { config, user, ... }:
    {
      sops.secrets.user-password = {
        sopsFile = ../secrets/common.yaml;
        neededForUsers = true;
      };

      users.users.${user}.hashedPasswordFile = config.sops.secrets.user-password.path;
    };
}
