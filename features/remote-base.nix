{
  nixos =
    { config, user, ... }:
    {
      sops.secrets.user-password = {
        sopsFile = ../secrets/common.yaml;
        neededForUsers = true;
      };

      users.mutableUsers = false;
      users.users.${user}.hashedPasswordFile = config.sops.secrets.user-password.path;
    };
}
