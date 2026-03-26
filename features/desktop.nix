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

      # bluetooth
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;

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

      programs.thunderbird.enable = true;
      programs._1password.enable = true;
      programs._1password-gui.enable = true;

      environment.systemPackages = with pkgs; [
        easyeffects
        ghostty
        google-chrome
        zathura
        pavucontrol
        bolt-launcher
        libnotify
        bibata-cursors
        vesktop
        rocketchat-desktop
        telegram-desktop
        slack
        jellyfin-media-player
        cider-2
        mpv
        ffmpeg
        wf-recorder
        wl-mirror
        protonmail-bridge
        ledger-live-desktop
      ];

      # internal CA
      security.pki.certificateFiles = [
        inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system}.ca-matheo-si
      ];

      xdg.mime.defaultApplications = {
        "application/pdf" = "org.pwmt.zathura.desktop";
      };
    };

  home =
    { inputs, ... }:
    {
      home.file.".assets".source = inputs.assets;
    };
}
