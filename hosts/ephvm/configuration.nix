{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # no hardware firmware needed in a VM
  hardware.enableRedistributableFirmware = lib.mkForce false;
  hardware.wirelessRegulatoryDatabase = lib.mkForce false;

  documentation.enable = false;
  environment.defaultPackages = [ ];

  # compressed qcow2, no channel copy
  image.modules.qemu =
    { config, modulesPath, ... }:
    {
      system.build.image = lib.mkForce (
        import (modulesPath + "/../lib/make-disk-image.nix") {
          inherit lib config pkgs;
          inherit (config.virtualisation) diskSize;
          inherit (config.image) baseName;
          format = "qcow2-compressed";
          copyChannel = false;
          partitionTableType = "legacy";
        }
      );
    };

  vm-guest.headless = true;

  vm-9p-automount.user = "matej";

  localisation = {
    timeZone = "UTC";
    defaultLocale = "en_US.UTF-8";
  };

  home-manager.users.matej = {
    neovim.dotfiles = inputs.nvim;
  };

  # ensure .config exists with correct ownership before automount
  systemd.tmpfiles.rules = [ "d /home/matej/.config 0755 matej users -" ];

  # writable claude config via 9p
  fileSystems."/home/matej/.config/claude" = {
    device = "claude";
    fsType = "9p";
    options = [
      "trans=virtio"
      "version=9p2000.L"
      "nofail"
      "x-systemd.automount"
    ];
  };

  environment.sessionVariables.CLAUDE_CONFIG_DIR = "/home/matej/.config/claude";

  system.stateVersion = "25.11";
}
