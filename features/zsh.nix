{
  nixos =
    { config, lib, pkgs, user, ... }:
    let
      cfg = config.features.zsh;
    in
    {
      options.features.zsh = {
        enable = lib.mkEnableOption "zsh";

        loginShell.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;

        };
      };

      config = lib.mkIf cfg.enable (lib.mkMerge [
        {
          programs.zsh.enable = true;
          environment.etc."zshenv".text = ''
            export ZDOTDIR=$HOME/.config/zsh
          '';
        }

        (lib.mkIf cfg.loginShell.enable {
          users.users.${user}.shell = pkgs.zsh;
        })
      ]);
    };

  home =
    { pkgs, lib, osConfig, ... }:
    let
      cfg = osConfig.features.zsh;
    in
    {
      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.starship ];
      };
    };
}
