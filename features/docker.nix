{
  nixos =
    { user, ... }:
    {
      virtualisation.docker = {
        enable = true;
        logDriver = "json-file";
      };

      users.users.${user}.extraGroups = [ "docker" ];
    };
}
