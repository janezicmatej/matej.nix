{
  nixos =
    { lib, ... }:
    {
      options.features.shell.enable = lib.mkEnableOption "shell extras";
    };

  home =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    let
      cfg = osConfig.features.shell;
    in
    {
      config = lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          fzf
          htop
          jc
          jq
          openssl
          pv
          ripgrep
          fd
          tmux
        ];
      };
    };
}
