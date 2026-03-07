{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    shell.enable = lib.mkEnableOption "shell utilities";
  };

  config = lib.mkIf config.shell.enable {
    home.packages = with pkgs; [
      starship
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
}
