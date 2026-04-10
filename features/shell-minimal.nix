{
  nixos = _: {
    programs.zsh.enable = true;
    environment.etc."zshenv".text = ''
      export ZDOTDIR=$HOME/.config/zsh
    '';
  };

  home =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        starship
      ];
    };
}
