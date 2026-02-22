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
    inputs.self.nixosModules.initrd-ssh
  ];

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

  initrd-ssh = {
    enable = true;
    networkModule = "r8169";
  };

  stylix = {
    enable = true;
    polarity = "dark";
    image = "${inputs.assets}/wallpaper.png";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";
  };

  # lanzaboote secure boot
  boot.kernelParams = [ "btusb.reset=1" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  time.timeZone = "Europe/Ljubljana";
  environment.variables.TZ = "Europe/Ljubljana";

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

  xdg.mime.defaultApplications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
  };

  system.stateVersion = "25.05";
}
