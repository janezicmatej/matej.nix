{
  lib,
  options,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-16-amd-ai-300-series
  ];

  features.desktop.bluetooth.enable = true;
  features.gnupg.yubikey.enable = true;
  features.udev = {
    ledger.enable = true;
    keyboard-zsa.enable = true;
  };
  features.power.resumeDevice = "/dev/disk/by-uuid/ff4750e7-3a9f-42c2-bb68-c458a6560540";

  boot.kernelParams = [ "pcie_aspm.policy=powersupersave" ];

  programs.nix-ld.libraries = options.programs.nix-ld.libraries.default;

  services.gnome.gnome-keyring.enable = true;
  services.teamviewer.enable = true;

  services.hardware.bolt.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.inputmodule.enable = true;

  # NOTE:(@janezicmatej) disable wakeup for framework input modules to prevent spurious wakes
  services.udev.extraRules = lib.mkAfter ''
    SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", ATTR{power/wakeup}="disabled"
    SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0014", ATTR{power/wakeup}="disabled"
  '';

  networking.firewall.enable = false;

  system.stateVersion = "24.11";
}
