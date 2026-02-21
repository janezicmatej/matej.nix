{
  lib,
  config,
  ...
}:
{
  options = {
    zsh = {
      enable = lib.mkEnableOption "zsh with ZDOTDIR in ~/.config/zsh";
    };
  };

  config = lib.mkIf config.zsh.enable {
    programs.zsh.enable = true;
    environment.etc."zshenv".text = ''
      export ZDOTDIR=$HOME/.config/zsh
    '';
  };
}
