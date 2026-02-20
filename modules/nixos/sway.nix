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
        description = "additional command line flags to pass to sway";
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
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
    };

    environment.systemPackages = with pkgs; [
      # default extra packages
      brightnessctl
      foot
      grim
      pulseaudio
      swayidle
      # swaylock - use swaylock-effects instead
      swaylock-effects
      wmenu
      # additional things i like
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
