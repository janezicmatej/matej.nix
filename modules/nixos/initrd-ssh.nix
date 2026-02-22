{
  lib,
  config,
  ...
}:
let
  # TODO:(@janezicmatej) restructure keys import
  keys = import ../../users/matej/keys.nix;

  cfg = config.initrd-ssh;

  # generate host keys for new machines: ./scripts/initrd-ssh-keygen.sh
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
          example = "10.222.0.247";
        };

        gateway = lib.mkOption {
          type = lib.types.str;
          example = "10.222.0.1";
        };

        netmask = lib.mkOption {
          type = lib.types.str;
          default = "255.255.255.0";
        };

        interface = lib.mkOption {
          type = lib.types.str;
          example = "enp5s0";
        };
      };

      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = keys.sshAuthorizedKeys;
      };

      networkModule = lib.mkOption {
        type = lib.types.str;
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
