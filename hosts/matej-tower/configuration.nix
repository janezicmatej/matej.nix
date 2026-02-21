{
  config,
  lib,
  pkgs,
  inputs,
  options,
  ...
}:

{
  networking.hostName = "matej-tower";
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
    inputs.self.nixosModules.tuigreet
    inputs.self.nixosModules.workstation
  ];

  # Modules
  yubikey.enable = true;
  openssh.enable = true;
  desktop.enable = true;
  printing.enable = true;
  zsh.enable = true;
  gnupg.enable = true;
  workstation.enable = true;
  tuigreet = {
    enable = true;
    command = "sway";
  };
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

  # Services
  services.udisks2.enable = true;

  # Programs
  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  # Higher sample rate pipewire for audio equipment
  services.pipewire.extraConfig.pipewire.adjust-sample-rate = {
    "context.properties" = {
      "default.clock.rate" = 192000;
      "default.allowed-rates" = [ 192000 ];
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    easyeffects
  ];

  # XDG
  xdg.mime.defaultApplications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
  };

  system.stateVersion = "25.05";
}
