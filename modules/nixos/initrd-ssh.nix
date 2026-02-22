{
  lib,
  config,
  ...
}:
let
  # TODO:(@janezicmatej) restructure keys import
  keys = import ../../users/matej/keys.nix;

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

  config = lib.mkIf config.initrd-ssh.enable {
    boot.initrd.kernelModules = [ config.initrd-ssh.networkModule ];
    boot.kernelParams = lib.mkIf config.initrd-ssh.ip.enable [
      "ip=${mkIpString config.initrd-ssh.ip}"
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
        inherit (config.initrd-ssh) authorizedKeys;
      };
      postCommands = ''
        echo 'cryptsetup-askpass' >> /root/.profile
      '';
    };
  };
}
