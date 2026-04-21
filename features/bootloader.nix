{
  nixos =
    {
      config,
      lib,
      inputs,
      ...
    }:
    let
      cfg = config.features.bootloader;
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

        plymouth.enable = lib.mkEnableOption "plymouth boot splash";
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            boot.loader.efi.canTouchEfiVariables = true;
            # request the largest framebuffer uefi offers; plymouth inherits it
            boot.loader.systemd-boot.consoleMode = "max";
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

          (lib.mkIf cfg.plymouth.enable {
            # plymouth needs systemd-initrd to render the luks prompt cleanly
            boot.initrd.systemd.enable = true;

            # host is responsible for early-KMS so plymouth lands on the gpu driver,
            # not simpledrm (e.g. hardware.amdgpu.initrd.enable on amd hosts)
            boot.plymouth.enable = true;
            stylix.targets.plymouth.logoAnimated = false;

            boot.kernelParams = [
              "quiet"
              "splash"
              "loglevel=3"
              "rd.systemd.show_status=false"
              "rd.udev.log_level=3"
              "udev.log_priority=3"
              "plymouth.force-scale=1"
            ];
            boot.consoleLogLevel = 0;
            boot.initrd.verbose = false;
          })
        ]
      );
    };
}
