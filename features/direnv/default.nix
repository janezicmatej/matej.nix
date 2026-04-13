{
  nixos =
    {
      config,
      lib,
      inputs,
      ...
    }:
    let
      cfg = config.features.direnv;
    in
    {
      options.features.direnv.enable = lib.mkEnableOption "direnv";

      config = lib.mkIf cfg.enable {
        nix.registry.dev = {
          from = {
            type = "indirect";
            id = "dev";
          };
          to = {
            type = "path";
            path = inputs.self.outPath;
          };
        };
      };
    };

  home =
    { lib, osConfig, ... }:
    let
      cfg = osConfig.features.direnv;
    in
    {
      config = lib.mkIf cfg.enable {
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
          config.global.hide_env_diff = true;
        };

        xdg.configFile."direnv/lib/use_dev.sh".source = ./use_dev.sh;
      };
    };
}
