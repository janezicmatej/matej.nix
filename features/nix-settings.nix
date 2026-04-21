{
  nixos =
    { config, lib, ... }:
    let
      cfg = config.features.nix-settings;
    in
    {
      options.features.nix-settings = {
        enable = lib.mkEnableOption "nix settings";

        towerCache.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;

        };

        gc = {
          dates = lib.mkOption {
            type = lib.types.str;
            default = "monthly";
          };

          olderThan = lib.mkOption {
            type = lib.types.str;
            default = "30d";
          };
        };

        optimise.dates = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "monthly" ];
        };
      };

      config = lib.mkIf cfg.enable {
        nix = {
          settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            download-buffer-size = 2 * 1024 * 1024 * 1024;
            download-attempts = 3;
            fallback = true;
            warn-dirty = false;
            substituters = [
              "https://cache.nixos.org"
              "https://nix-community.cachix.org?priority=45"
            ]
            ++ lib.optional cfg.towerCache.enable "http://tower:5000?priority=50";
            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ]
            ++ lib.optional cfg.towerCache.enable "matej.nix-1:TdbemLVYblvAxqJcwb3mVKmmr3cfzXbMcZHE5ILnZDE=";
          };

          gc = {
            automatic = true;
            inherit (cfg.gc) dates;
            options = "--delete-older-than ${cfg.gc.olderThan}";
          };

          optimise = {
            automatic = true;
            inherit (cfg.optimise) dates;
          };
        };
      };
    };
}
