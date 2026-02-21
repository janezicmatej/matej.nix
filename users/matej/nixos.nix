{
  lib,
  config,
  pkgs,
  ...
}:
let
  keys = import ./keys.nix;
in
{
  users.users.matej = {
    uid = 1000;
    isNormalUser = true;
    home = "/home/matej";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = keys.sshAuthorizedKeys;
  };

  users.groups.matej = {
    gid = 1000;
    members = [ "matej" ];
  };
}
