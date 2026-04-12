{
  nixos =
    { config, lib, pkgs, inputs, ... }:
    let
      cfg = config.features.desktop;
    in
    {
      options.features.desktop = {
        enable = lib.mkEnableOption "desktop environment";

        audio.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };

        bluetooth.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        apps.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };

        theme = {
          wallpaper = lib.mkOption {
            type = lib.types.path;
            default = "${inputs.assets}/wallpaper.png";
          };

          scheme = lib.mkOption {
            type = lib.types.str;
            default = "gruvbox-material-dark-medium";
          };

          polarity = lib.mkOption {
            type = lib.types.enum [
              "dark"
              "light"
            ];
            default = "dark";
          };
        };

        internalCA.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      };

      config = lib.mkIf cfg.enable (lib.mkMerge [
        # base desktop
        {
          security.polkit.enable = true;
          services.dbus.enable = true;
          services.playerctld.enable = true;

          xdg.portal = {
            enable = true;
            xdgOpenUsePortal = true;
            extraPortals = with pkgs; [
              xdg-desktop-portal-wlr
              xdg-desktop-portal-gtk
            ];
          };

          fonts.packages = with pkgs; [
            font-awesome
            nerd-fonts.jetbrains-mono
          ];

          stylix = {
            enable = true;
            polarity = cfg.theme.polarity;
            image = cfg.theme.wallpaper;
            base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.theme.scheme}.yaml";
          };
        }

        # audio
        (lib.mkIf cfg.audio.enable {
          services.pipewire = {
            enable = true;
            pulse.enable = true;
          };
          environment.systemPackages = with pkgs; [
            pavucontrol
            easyeffects
          ];
        })

        # bluetooth
        (lib.mkIf cfg.bluetooth.enable {
          hardware.bluetooth.enable = true;
          services.blueman.enable = true;
        })

        # apps
        (lib.mkIf cfg.apps.enable {
          programs.thunderbird.enable = true;

          environment.systemPackages = with pkgs; [
            ghostty
            google-chrome
            zathura
            calibre
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

          xdg.mime.defaultApplications = {
            "application/pdf" = "org.pwmt.zathura.desktop";
          };

          # kindle udev rules for calibre
          features.udev.kindle.enable = lib.mkDefault true;
        })

        # internal CA
        (lib.mkIf cfg.internalCA.enable {
          security.pki.certificateFiles = [
            inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system}.ca-matheo-si
          ];
        })
      ]);
    };

  home =
    { lib, inputs, osConfig, ... }:
    let
      cfg = osConfig.features.desktop;
    in
    {
      config = lib.mkIf cfg.enable {
        home.file.".assets".source = inputs.assets;
      };
    };
}
