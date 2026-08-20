{ lib, userKeys, modulesPath, ... }:
{
  imports = [
    # This built-in module sets up the mock root fs and ISO bootloader automatically
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  boot.zfs.forceImportRoot = false;

  features.nix-settings.towerCache.enable = false;
  image.modules.iso-installer = {
    isoImage.squashfsCompression = "zstd -Xcompression-level 6";
  };

  # live iso: passwordless login and sudo
  users.users.matej.initialHashedPassword = "";
  users.users.root.openssh.authorizedKeys.keys = userKeys.sshAuthorizedKeys;
  services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
