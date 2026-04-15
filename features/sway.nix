{
  nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.sway;
      desktopCfg = config.features.desktop;
    in
    {
      options.features.sway = {
        enable = lib.mkEnableOption "sway window manager";

        greeter.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            # soft dependency
            features.desktop.enable = lib.mkDefault true;

            # hard dependency
            assertions = [
              {
                assertion = desktopCfg.enable;
                message = "features.sway requires features.desktop";
              }
            ];

            programs.sway = {
              enable = true;
              package = pkgs.swayfx;
              wrapperFeatures.gtk = true;
              extraSessionCommands = ''
                # fix for java awt apps not rendering
                export _JAVA_AWT_WM_NONREPARENTING=1
                # propagate XDG_DATA_DIRS to dbus/systemd for d-bus activated apps
                dbus-update-activation-environment --systemd XDG_DATA_DIRS
              '';
            };

            environment.systemPackages = with pkgs; [
              waybar
              mako
              wob
              playerctl
              brightnessctl
              foot
              grim
              pulseaudio
              swayidle
              swaylock-effects
              jq
              slurp
              wl-clipboard
              pamixer
              wlsunset
              satty
              wayland-pipewire-idle-inhibit
              fuzzel
              cliphist
              zenity
            ];
          }

          # greeter
          (lib.mkIf cfg.greeter.enable {
            programs.regreet = {
              enable = true;
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
                  path = lib.mkForce (toString desktopCfg.theme.wallpaper);
                  fit = lib.mkForce "Cover";
                };
                GTK = {
                  application_prefer_dark_theme = lib.mkForce true;
                };
              };
            };
          })
        ]
      );
    };
}
