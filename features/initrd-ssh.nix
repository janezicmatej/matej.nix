{
  nixos =
    { lib, config, ... }:
    let
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
          ip = {
            enable = lib.mkEnableOption "static IP for initrd (otherwise DHCP)";

            address = lib.mkOption {
              type = lib.types.str;
            };

            gateway = lib.mkOption {
              type = lib.types.str;
            };

            netmask = lib.mkOption {
              type = lib.types.str;
              default = "255.255.255.0";
            };

            interface = lib.mkOption {
              type = lib.types.str;
            };
          };

          authorizedKeys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };

          networkModule = lib.mkOption {
            type = lib.types.str;
          };
        };
      };

      config = {
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
    };
}
