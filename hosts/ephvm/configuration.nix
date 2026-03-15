{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  networking.hostName = "ephvm";

  profiles.base.enable = true;

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

  vm-guest = {
    enable = true;
    headless = true;
  };

  vm-9p-automount = {
    enable = true;
    user = "matej";
  };

  localisation = {
    timeZone = "UTC";
    defaultLocale = "en_US.UTF-8";
  };

  virtualisation.docker = {
    enable = true;
    logDriver = "json-file";
  };

  # TODO:(@janezicmatej) move neovim dotfiles wiring to a cleaner place
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
