{
  config,
  lib,
  pkgs,
  inputs,
  options,
  ...
}:

let
  packages = inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system};
in

{
  imports = [
    inputs.stylix.nixosModules.stylix
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

  sway = {
    enable = true;
    cmdFlags = [ "--unsupported-gpu" ];
  };

  # Stylix theming
  stylix = {
    enable = true;
    polarity = "dark";
    image = "${inputs.assets}/wallpaper.png";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";
  };

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Locale
  time.timeZone = "Europe/Ljubljana";
  environment.variables.TZ = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Docker
  virtualisation.docker = {
    enable = true;
    logDriver = "json-file";
  };

  # nix-ld for pip-installed binaries
  # WARN:(matej) probably want to drop this in the future
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = options.programs.nix-ld.libraries.default;

  # Security
  security.pki.certificateFiles = [ packages.ca-matheo-si ];
  services.gnome.gnome-keyring.enable = true;

  # Services
  services.teamviewer.enable = true;
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

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
  programs.thunderbird.enable = true;
  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Hardware
  hardware.keyboard.zsa.enable = true;
  hardware.ledger.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    smartmontools
  ];

  # XDG
  xdg.mime.defaultApplications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
  };

  system.stateVersion = "24.11";
}
