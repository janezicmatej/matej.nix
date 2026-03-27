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

  users.users.matej.hashedPassword = "$6$59Z5NIkOYZ3eSElX$FehMGGXQlC040G8eoO42JQDScb7hI04NbdVMAkKYKqVOLTO/.MJxfk8fHypQHrCdtAs67N1bnU2s5H/3zLWhC1";

  localisation = {
    timeZone = "Europe/Ljubljana";
    defaultLocale = "en_US.UTF-8";
  };

  system.stateVersion = "25.11";
}
