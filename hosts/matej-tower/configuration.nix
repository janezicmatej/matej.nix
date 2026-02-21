{
  config,
  lib,
  pkgs,
  inputs,
  options,
  ...
}:

{
  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.self.nixosModules.yubikey
    inputs.self.nixosModules.sway
    inputs.self.nixosModules.openssh
    inputs.self.nixosModules.desktop
    inputs.self.nixosModules.printing
    inputs.self.nixosModules.zsh
    inputs.self.nixosModules.gnupg
  ];

  # Modules
  yubikey.enable = true;
  openssh.enable = true;
  desktop.enable = true;
  printing.enable = true;
  zsh.enable = true;
  gnupg.enable = true;
  sway.enable = true;

  # Stylix theming
  stylix = {
    enable = true;
    polarity = "dark";
    image = "${inputs.assets}/wallpaper.png";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";
  };

  # Boot - Lanzaboote secure boot
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Locale
  time.timeZone = "Europe/Ljubljana";
  environment.variables.TZ = "Europe/Ljubljana";

  # Docker
  virtualisation.docker = {
    enable = true;
    logDriver = "json-file";
  };

  # Services
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };
  services.udisks2.enable = true;

  # Greetd
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
        user = "greeter";
      };
    };
  };

  # Programs
  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  # Higher sample rate pipewire for audio equipment
  services.pipewire.extraConfig.pipewire.adjust-sample-rate = {
    "context.properties" = {
      "default.clock.rate" = 192000;
      "defautlt.allowed-rates" = [ 192000 ];
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    smartmontools
    easyeffects
  ];

  # XDG
  xdg.mime.defaultApplications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
  };

  system.stateVersion = "25.05";
}
