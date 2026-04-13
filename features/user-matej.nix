let
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQGLdINKzs+sEy62Pefng0bcedgU396+OryFgeH99/c janezicmatej"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDk00+Km03epQXQs+xEwwH3zcurACzkEH+kDOPBw6RQe openpgp:0xB095D449"
  ];
in
{
  keys = {
    sshAuthorizedKeys = sshKeys;
  };

  nixos = _: {
    users.users.matej = {
      uid = 1000;
      isNormalUser = true;
      home = "/home/matej";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = sshKeys;
    };

    users.groups.matej = {
      gid = 1000;
      members = [ "matej" ];
    };
  };

  home = _: {
    home.stateVersion = "26.05";
  };
}
