{
  nixos =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
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

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          # base desktop
          {
            security.polkit.enable = true;
            services.dbus.enable = true;
            services.playerctld.enable = true;

            xdg.portal = {
              enable = true;
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
              inherit (cfg.theme) polarity;
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
              imv
              yazi
              nemo
              file-roller
              libreoffice-still
            ];

            # kindle udev rules for calibre
            features.udev.kindle.enable = lib.mkDefault true;
          })

          # internal CA
          (lib.mkIf cfg.internalCA.enable {
            security.pki.certificateFiles = [
              inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system}.ca-matheo-si
            ];
          })
        ]
      );
    };

  home =
    {
      lib,
      inputs,
      osConfig,
      ...
    }:
    let
      cfg = osConfig.features.desktop;
    in
    {
      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            home.file.".assets".source = inputs.assets;
          }

          (lib.mkIf cfg.apps.enable {
            # TODO:(@janezicmatej) consider moving nvim desktop entry to neovim feature
            xdg.desktopEntries.nvim = {
              name = "Neovim";
              exec = "ghostty -e nvim %F";
              terminal = false;
              mimeType = [
                "text/plain"
                "application/json"
                "text/markdown"
              ];
            };

            xdg.mimeApps = {
              enable = true;
              defaultApplications = {
                # text
                "text/plain" = "nvim.desktop";
                "application/json" = "nvim.desktop";
                "text/markdown" = "nvim.desktop";

                # web
                "text/html" = "google-chrome.desktop";
                "application/xhtml+xml" = "google-chrome.desktop";
                "x-scheme-handler/http" = "google-chrome.desktop";
                "x-scheme-handler/https" = "google-chrome.desktop";
                "x-scheme-handler/ftp" = "google-chrome.desktop";
                "x-scheme-handler/about" = "google-chrome.desktop";
                "x-scheme-handler/unknown" = "google-chrome.desktop";

                # mail and calendar
                "x-scheme-handler/mailto" = "thunderbird.desktop";
                "message/rfc822" = "thunderbird.desktop";
                "text/calendar" = "thunderbird.desktop";

                # documents
                "application/pdf" = "org.pwmt.zathura.desktop";
                "application/postscript" = "org.pwmt.zathura.desktop";
                "image/vnd.djvu" = "org.pwmt.zathura.desktop";
                "application/epub+zip" = "org.pwmt.zathura.desktop";

                # office
                "application/msword" = "libreoffice-writer.desktop";
                "application/vnd.ms-excel" = "libreoffice-calc.desktop";
                "application/vnd.ms-powerpoint" = "libreoffice-impress.desktop";
                "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
                  "libreoffice-writer.desktop";
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "libreoffice-calc.desktop";
                "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
                  "libreoffice-impress.desktop";
                "application/vnd.oasis.opendocument.text" = "libreoffice-writer.desktop";
                "application/vnd.oasis.opendocument.spreadsheet" = "libreoffice-calc.desktop";
                "application/vnd.oasis.opendocument.presentation" = "libreoffice-impress.desktop";
                "text/csv" = "libreoffice-calc.desktop";

                # images
                "image/png" = "imv-dir.desktop";
                "image/jpeg" = "imv-dir.desktop";
                "image/gif" = "imv-dir.desktop";
                "image/webp" = "imv-dir.desktop";
                "image/tiff" = "imv-dir.desktop";
                "image/bmp" = "imv-dir.desktop";
                "image/svg+xml" = "google-chrome.desktop";

                # video
                "video/mp4" = "mpv.desktop";
                "video/x-matroska" = "mpv.desktop";
                "video/webm" = "mpv.desktop";
                "video/quicktime" = "mpv.desktop";
                "video/x-msvideo" = "mpv.desktop";

                # audio
                "audio/mpeg" = "mpv.desktop";
                "audio/flac" = "mpv.desktop";
                "audio/ogg" = "mpv.desktop";
                "audio/wav" = "mpv.desktop";
                "audio/aac" = "mpv.desktop";

                # archives
                "application/zip" = "org.gnome.FileRoller.desktop";
                "application/x-tar" = "org.gnome.FileRoller.desktop";
                "application/gzip" = "org.gnome.FileRoller.desktop";
                "application/x-rar-compressed" = "org.gnome.FileRoller.desktop";
                "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
                "application/x-bzip2" = "org.gnome.FileRoller.desktop";
                "application/x-xz" = "org.gnome.FileRoller.desktop";

                # file manager
                "inode/directory" = "nemo.desktop";

                # app deep links
                "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
                "x-scheme-handler/discord" = "vesktop.desktop";
                "x-scheme-handler/slack" = "slack.desktop";
              };
            };
          })
        ]
      );
    };
}
