{
  nixos =
    { lib, config, ... }:
    let
      cfg = config.features.initrd-ssh;
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
      options.features.initrd-ssh = {
        enable = lib.mkEnableOption "initrd ssh";

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

      config = lib.mkIf cfg.enable {
        boot.initrd.availableKernelModules = [ cfg.networkModule ];
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
            inherit (cfg) authorizedKeys;
          };
          postCommands = ''
            echo 'cryptsetup-askpass' >> /root/.profile
          '';
        };
      };
    };
}
