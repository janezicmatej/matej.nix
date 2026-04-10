{
  nixos =
    { pkgs, inputs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      # audio
      services.pipewire = {
        enable = true;
        pulse.enable = true;
      };

      security.polkit.enable = true;
      services.dbus.enable = true;
      services.playerctld.enable = true;

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-wlr
          pkgs.xdg-desktop-portal-gtk
        ];
      };

      fonts.packages = with pkgs; [
        font-awesome
        nerd-fonts.jetbrains-mono
      ];

      # theming
      stylix = {
        enable = true;
        polarity = "dark";
        image = "${inputs.assets}/wallpaper.png";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";
      };
    };

  home =
    { inputs, ... }:
    {
      home.file.".assets".source = inputs.assets;
    };
}
