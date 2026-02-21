{
  lib,
  config,
  ...
}:
let
  # TODO:(@janezicmatej) restructure keys import
  keys = import ../../users/matej/keys.nix;

  cfg = config.initrd-ssh;

  # Generate keys on new machines: ./scripts/initrd-ssh-keygen.sh
  keyDir = "/etc/secrets/initrd";

  mkIpString =
    {
      address,
      gateway,
      netmask,
      interface,
      ...
    }:
    "${address}::${gateway}:${netmask}::${interface}:none";
in
{
  options = {
    initrd-ssh = {
      enable = lib.mkEnableOption "SSH in initrd for remote LUKS unlock";

      ip = {
        enable = lib.mkEnableOption "static IP for initrd (otherwise DHCP)";

        address = lib.mkOption {
          type = lib.types.str;
          description = "Static IP address";
          example = "10.222.0.247";
        };

        gateway = lib.mkOption {
          type = lib.types.str;
          description = "Gateway address";
          example = "10.222.0.1";
        };

        netmask = lib.mkOption {
          type = lib.types.str;
          default = "255.255.255.0";
          description = "Network mask";
        };

        interface = lib.mkOption {
          type = lib.types.str;
          description = "Network interface";
          example = "enp5s0";
        };
      };

      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = keys.sshAuthorizedKeys;
        description = "SSH public keys authorized for initrd unlock";
      };

      networkModule = lib.mkOption {
        type = lib.types.str;
        description = "Kernel module for network interface (e.g., r8169, e1000e)";
        example = "r8169";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.kernelModules = [ cfg.networkModule ];
    boot.kernelParams = lib.mkIf cfg.ip.enable [
      "ip=${mkIpString cfg.ip}"
    ];

    boot.initrd.network = {
      enable = true;
      ssh = {
        enable = true;
        port = 22;
        hostKeys = [
          "${keyDir}/ssh_host_rsa_key"
          "${keyDir}/ssh_host_ed25519_key"
        ];
        authorizedKeys = cfg.authorizedKeys;
      };
      postCommands = ''
        echo 'cryptsetup-askpass' >> /root/.profile
      '';
    };
  };
}
