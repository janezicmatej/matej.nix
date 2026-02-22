{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    sway = {
      enable = lib.mkEnableOption "enable sway module";
      cmdFlags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  config = lib.mkIf config.sway.enable {
    programs.sway = {
      enable = true;
      package = pkgs.swayfx;
      wrapperFeatures.gtk = true;
      extraOptions = config.sway.cmdFlags;
      extraSessionCommands = ''
        # fix for java awt apps not rendering
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
    };

    environment.systemPackages = with pkgs; [
      brightnessctl
      foot
      grim
      pulseaudio
      swayidle
      # use swaylock-effects instead of swaylock
      swaylock-effects
      wmenu
      slurp
      wofi
      wl-clipboard
      wob
      pamixer
      wlsunset
      flameshot
      waybar
      wayland-pipewire-idle-inhibit
    ];
  };
}
