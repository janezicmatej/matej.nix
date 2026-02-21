{ pkgs, lib, inputs, ... }:
let
  keys = import ../../users/matej/keys.nix;
in
{
  imports = [
    inputs.self.nixosModules.openssh
  ];

  openssh.enable = true;

  image.modules.iso-installer = {
    isoImage.squashfsCompression = "zstd -Xcompression-level 6";
  };

  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.loader.grub.device = lib.mkDefault "/dev/sda";

  networking.firewall.allowedTCPPorts = [ 22 ];

  users = {
    groups.matej = {
      gid = 1000;
    };
    users.matej = {
      group = "matej";
      uid = 1000;
      isNormalUser = true;
      home = "/home/matej";
      createHome = true;
      password = "burek123";
      extraGroups = [
        "wheel"
        "users"
      ];
      openssh.authorizedKeys.keys = keys.sshAuthorizedKeys;
    };
  };

  system.stateVersion = "25.05";
}
