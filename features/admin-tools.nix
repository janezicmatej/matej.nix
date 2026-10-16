{
  nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.admin-tools;
    in
    {
      options.features.admin-tools.enable = lib.mkEnableOption "admin and diagnostic tools";

      config = lib.mkIf cfg.enable {
        # mtr-packet needs a cap_net_raw wrapper to run as a user
        programs.mtr.enable = true;

        environment.systemPackages = with pkgs; [
          # hardware inspection
          pciutils
          usbutils
          lshw
          dmidecode
          lm_sensors
          smartmontools
          nvme-cli

          # processes and io
          lsof
          psmisc
          strace
          iotop-c
          sysstat

          # network
          ethtool
          tcpdump
          dnsutils

          # files
          file
          tree
          unzip
        ];
      };
    };
}
