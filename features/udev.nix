{
  nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.udev;
    in
    {
      options.features.udev = {
        enable = lib.mkEnableOption "custom udev rules";

        kindle.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        ledger.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        keyboard-zsa.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          (lib.mkIf cfg.kindle.enable {
            # NOTE:(@janezicmatej) uses services.udev.packages instead of extraRules
            # because extraRules writes to 99-local.rules which is too late for uaccess
            services.udev.packages = [
              pkgs.libmtp
              (pkgs.writeTextFile {
                name = "kindle-udev-rules";
                text = ''
                  ACTION!="remove", SUBSYSTEM=="usb", ATTRS{idVendor}=="1949", TAG+="uaccess"
                '';
                destination = "/etc/udev/rules.d/70-kindle.rules";
              })
            ];
          })

          (lib.mkIf cfg.ledger.enable {
            hardware.ledger.enable = true;
          })

          (lib.mkIf cfg.keyboard-zsa.enable {
            hardware.keyboard.zsa.enable = true;
          })
        ]
      );
    };
}
