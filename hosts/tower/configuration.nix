{
  config,
  userKeys,
  ...
}:

{
  features.nix-settings.towerCache.enable = false;
  features.bootloader = {
    mode = "lanzaboote";
    plymouth.enable = true;
  };
  features.desktop.bluetooth.enable = true;
  features.gnupg.yubikey.enable = true;
  features.udev = {
    ledger.enable = true;
    keyboard-zsa.enable = true;
  };
  features.initrd-ssh = {
    networkModule = "r8169";
    authorizedKeys = userKeys.sshAuthorizedKeys;
  };

  # nix store signing
  sops.secrets.nix-signing-key.sopsFile = ../../secrets/tower.yaml;
  nix.settings.secret-key-files = [ config.sops.secrets.nix-signing-key.path ];

  boot.kernelParams = [ "btusb.reset=1" ];
  # early kms so plymouth lands on amdgpu, not simpledrm
  hardware.amdgpu.initrd.enable = true;

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
