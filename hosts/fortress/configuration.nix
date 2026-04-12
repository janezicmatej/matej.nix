{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.framework-16-amd-ai-300-series
  ];

  features.desktop = {
    apps.enable = false;
    internalCA.enable = false;
  };
  features.gnupg.yubikey.enable = true;

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptlvm";
            settings.allowDiscards = true;
            content = {
              type = "lvm_pv";
              vg = "vg";
            };
          };
        };
      };
    };
  };

  disko.devices.lvm_vg.vg = {
    type = "lvm_vg";
    lvs = {
      root = {
        size = "100%FREE";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/";
        };
      };
      swap = {
        size = "32G";
        content = {
          type = "swap";
        };
      };
    };
  };

  networking.firewall.enable = true;

  environment.systemPackages = with pkgs; [
    google-chrome
    firefox
    vim
  ];

  system.stateVersion = "25.11";
}
