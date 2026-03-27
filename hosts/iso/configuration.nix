_: {
  image.modules.iso-installer = {
    isoImage.squashfsCompression = "zstd -Xcompression-level 6";
  };

  # live iso: passwordless login and sudo
  users.users.matej.initialHashedPassword = "";
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
