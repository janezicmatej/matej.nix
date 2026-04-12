{
  nixos =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.gnupg;
    in
    {
      options.features.gnupg = {
        enable = lib.mkEnableOption "gnupg";

        yubikey.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };

      config = lib.mkIf cfg.enable (lib.mkMerge [
        {
          programs.gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
            enableExtraSocket = true;
          };
        }

        (lib.mkIf cfg.yubikey.enable {
          environment.systemPackages = with pkgs; [
            yubikey-personalization
            yubikey-manager
          ];

          services.pcscd.enable = true;
        })
      ]);
    };
}
