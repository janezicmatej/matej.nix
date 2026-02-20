{ pkgs, lib, ... }:
{
  # Use zstd instead of xz for compressing the liveUSB image, it's 6x faster and 15% bigger.
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = null;
      PermitRootLogin = "no";
      StreamLocalBindUnlink = "yes";
    };
  };

  networking = {
    useDHCP = true;
    firewall.allowedTCPPorts = [ 22 ];
  };

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
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQGLdINKzs+sEy62Pefng0bcedgU396+OryFgeH99/c janezicmatej"
      ];
    };
  };

  # boot.extraModulePackages = [ pkgs.linuxPackages.r8125 ];
  # boot.blacklistedKernelModules = [ "r8169" ];

  system.stateVersion = "25.05";
}
