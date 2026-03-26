{
  lib,
  inputs,
  userKeys,
  ...
}:

{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  localisation = {
    timeZone = "Europe/Ljubljana";
    defaultLocale = "en_US.UTF-8";
  };

  initrd-ssh = {
    networkModule = "r8169";
    authorizedKeys = userKeys.sshAuthorizedKeys;
  };

  # lanzaboote secure boot
  boot.kernelParams = [ "btusb.reset=1" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  services.udisks2.enable = true;

  # higher sample rate for audio equipment
  services.pipewire.extraConfig.pipewire.adjust-sample-rate = {
    "context.properties" = {
      "default.clock.rate" = 192000;
      "default.allowed-rates" = [ 192000 ];
    };
  };

  system.stateVersion = "25.05";
}
