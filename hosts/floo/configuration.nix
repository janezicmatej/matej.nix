{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  features.filedrop.sopsFile = ../../secrets/floo.yaml;

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

  system.stateVersion = "25.11";
}
