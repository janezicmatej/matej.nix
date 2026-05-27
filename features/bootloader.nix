{
  nixos =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      cfg = config.features.bootloader;
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
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      options.features.bootloader = {
        enable = lib.mkEnableOption "bootloader";

        mode = lib.mkOption {
          type = lib.types.enum [
            "systemd-boot"
            "lanzaboote"
          ];
          default = "systemd-boot";
        };

        configurationLimit = lib.mkOption {
          type = lib.types.int;
          default = 10;
        };

        consoleFont = lib.mkOption {
          type = lib.types.str;
          default = "ter-v32n";
        };

        resumeDevice = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };

        initrdSsh = {
          enable = lib.mkEnableOption "remote LUKS unlock via ssh in initrd";

          networkModule = lib.mkOption {
            type = lib.types.str;
          };

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
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            boot.loader.efi.canTouchEfiVariables = true;

            # lanzaboote inherits editor + configurationLimit from systemd-boot.*
            boot.loader.systemd-boot = {
              editor = false;
              inherit (cfg) configurationLimit;
            };

            boot.initrd.systemd.enable = true;

            # wait forever at the luks prompt instead of timing out the device
            # job; applies whether the prompt is local or forwarded via initrd ssh
            boot.initrd.systemd.settings.Manager.DefaultDeviceTimeoutSec = "infinity";

            # block simpledrm so fbcon defers until the gpu driver binds; avoids
            # the simpledrm -> real-driver fbcon transition that mangles console
            # text and leaves the luks prompt typing offset from the visible
            # surface. hosts must put the gpu driver in initrd (nixos-hardware
            # does this for amd; manual hardware.amdgpu.initrd.enable on others)
            boot.kernelParams = [ "initcall_blacklist=simpledrm_platform_driver_init" ];

            # verbose boot: kernel messages and systemd unit lines visible end
            # to end. trade-off: the luks prompt will be interleaved with the
            # last few "Starting/Started ..." lines (no upstream fix exists
            # without plymouth). boot.initrd.verbose is a no-op under
            # systemd-initrd, so not set here.

            # readable luks prompt at panel-native dpi
            console = {
              earlySetup = true;
              font = cfg.consoleFont;
              packages = [ pkgs.terminus_font ];
            };
          }

          (lib.mkIf (cfg.mode == "systemd-boot") {
            boot.loader.systemd-boot.enable = true;
          })

          (lib.mkIf (cfg.mode == "lanzaboote") {
            boot.loader.systemd-boot.enable = lib.mkForce false;
            boot.lanzaboote = {
              enable = true;
              pkiBundle = "/var/lib/sbctl";
            };
          })

          (lib.mkIf (cfg.resumeDevice != null) {
            boot.resumeDevice = cfg.resumeDevice;
          })

          (lib.mkIf cfg.initrdSsh.enable {
            boot.initrd.availableKernelModules = [ cfg.initrdSsh.networkModule ];

            boot.kernelParams = lib.mkIf cfg.initrdSsh.ip.enable [
              "ip=${mkIpString cfg.initrdSsh.ip}"
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
                inherit (cfg.initrdSsh) authorizedKeys;
              };
            };

            # forward LUKS password prompt to the ssh session (systemd-initrd idiom)
            boot.initrd.systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";

            boot.initrd.systemd.network.networks = lib.mkIf (!cfg.initrdSsh.ip.enable) {
              "10-initrd" = {
                matchConfig.Driver = cfg.initrdSsh.networkModule;
                networkConfig.DHCP = "yes";
              };
            };
          })
        ]
      );
    };
}
