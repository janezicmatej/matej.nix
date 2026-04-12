{
  nixos =
    { config, lib, inputs, ... }:
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
      };

      config = lib.mkIf cfg.enable (lib.mkMerge [
        {
          boot.loader.efi.canTouchEfiVariables = true;
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
      ]);
    };
}
