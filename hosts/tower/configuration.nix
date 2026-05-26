{
  config,
  userKeys,
  ...
}:

{
  features.nix-settings.towerCache.enable = false;
  features.bootloader = {
    mode = "lanzaboote";
    initrdSsh = {
      enable = true;
      networkModule = "r8169";
      authorizedKeys = userKeys.sshAuthorizedKeys;
    };
  };
  features.desktop.bluetooth.enable = true;
  features.gnupg.yubikey.enable = true;
  features.udev = {
    ledger.enable = true;
    keyboard-zsa.enable = true;
  };

  # nix store signing
  sops.secrets.nix-signing-key.sopsFile = ../../secrets/tower.yaml;
  nix.settings.secret-key-files = [ config.sops.secrets.nix-signing-key.path ];

  boot.kernelParams = [ "btusb.reset=1" ];
  # pairs with bootloader's simpledrm initcall blacklist: amdgpu owns fbcon
  # from the start, no driver-swap mode-set
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
