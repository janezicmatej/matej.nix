{
  nixos =
    { inputs, ... }:
    {
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

  home = _: {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.global.hide_env_diff = true;
    };

    xdg.configFile."direnv/lib/use_dev.sh".source = ./use_dev.sh;
  };
}
