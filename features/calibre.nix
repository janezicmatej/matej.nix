{
  nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.calibre ];

      # udev rules for kindle and mtp device access
      # NOTE:(@janezicmatej) uses services.udev.packages instead of extraRules
      # because extraRules writes to 99-local.rules which is too late for uaccess
      # see https://github.com/NixOS/nixpkgs/issues/308681
      services.udev.packages = [
        pkgs.libmtp
        (pkgs.writeTextFile {
          name = "kindle-udev-rules";
          text = ''
            ACTION!="remove", SUBSYSTEM=="usb", ATTRS{idVendor}=="1949", TAG+="uaccess"
          '';
          destination = "/etc/udev/rules.d/70-kindle.rules";
        })
      ];
    };
}
