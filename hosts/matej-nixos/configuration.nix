{
  config,
  lib,
  pkgs,
  inputs,
  options,
  userKeys,
  ...
}:

let
  packages = inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system};
in

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-16-amd-ai-300-series
    inputs.stylix.nixosModules.stylix
  ];

  profiles.desktop.enable = true;

  localisation = {
    timeZone = "Europe/Ljubljana";
    defaultLocale = "en_US.UTF-8";
  };

  stylix = {
    enable = true;
    polarity = "dark";
    image = "${inputs.assets}/wallpaper.png";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # WARN:(@janezicmatej) nix-ld for running pip-installed binaries outside nix, probably want to drop this
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = options.programs.nix-ld.libraries.default;

  security.pki.certificateFiles = [ packages.ca-matheo-si ];
  services.gnome.gnome-keyring.enable = true;

  services.teamviewer.enable = true;

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

  services.hardware.bolt.enable = true;
  hardware.keyboard.zsa.enable = true;
  hardware.ledger.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.inputmodule.enable = true;

  programs.nm-applet.enable = true;

  networking = {
    hostName = "matej-nixos";
    networkmanager.enable = true;
    firewall.enable = false;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  xdg.mime.defaultApplications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
  };

  system.stateVersion = "24.11";
}
