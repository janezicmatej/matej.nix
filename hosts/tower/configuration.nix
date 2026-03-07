{
  config,
  lib,
  pkgs,
  inputs,
  options,
  userKeys,
  ...
}:

{
  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  profiles.desktop.enable = true;

  initrd-ssh = {
    enable = true;
    networkModule = "r8169";
    authorizedKeys = userKeys.sshAuthorizedKeys;
  };

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

  # neovim manages its own theme
  home-manager.users.matej.stylix.targets.neovim.enable = false;

  # lanzaboote secure boot
  boot.kernelParams = [ "btusb.reset=1" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  services.udisks2.enable = true;

  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  # higher sample rate for audio equipment
  services.pipewire.extraConfig.pipewire.adjust-sample-rate = {
    "context.properties" = {
      "default.clock.rate" = 192000;
      "default.allowed-rates" = [ 192000 ];
    };
  };

  environment.systemPackages = with pkgs; [
    easyeffects
  ];

  networking.hostName = "tower";

  xdg.mime.defaultApplications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
  };

  system.stateVersion = "25.05";
}
