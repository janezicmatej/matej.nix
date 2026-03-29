{ lib, ... }:
{
  image.modules.iso-installer = {
    isoImage.squashfsCompression = "zstd -Xcompression-level 6";
  };

  # live iso: passwordless login and sudo
  users.users.matej.initialHashedPassword = "";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQGLdINKzs+sEy62Pefng0bcedgU396+OryFgeH99/c janezicmatej"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDk00+Km03epQXQs+xEwwH3zcurACzkEH+kDOPBw6RQe openpgp:0xB095D449"
  ];
  services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
