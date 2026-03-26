{
  nixos =
    { pkgs, ... }:
    {
      programs.sway = {
        enable = true;
        package = pkgs.swayfx;
        wrapperFeatures.gtk = true;
        extraSessionCommands = ''
          # fix for java awt apps not rendering
          export _JAVA_AWT_WM_NONREPARENTING=1
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
    };
}
