{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  boot.loader.grub.enable = true;

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02";
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  localisation = {
    timeZone = "Europe/Ljubljana";
    defaultLocale = "en_US.UTF-8";
  };

  system.stateVersion = "25.11";
}
