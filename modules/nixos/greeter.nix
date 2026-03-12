{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  options = {
    greeter.enable = lib.mkEnableOption "greetd with regreet";
  };

  config = lib.mkIf config.greeter.enable {
    programs.regreet = {
      enable = true;
      # single output to avoid stretching across monitors
      cageArgs = [
        "-s"
        "-m"
        "last"
      ];
      font = {
        name = lib.mkForce "JetBrainsMono Nerd Font";
        size = lib.mkForce 14;
      };
      settings = {
        background = {
          path = lib.mkForce "${inputs.assets}/wallpaper.png";
          fit = lib.mkForce "Cover";
        };
        GTK = {
          application_prefer_dark_theme = lib.mkForce true;
        };
      };
    };
  };
}
