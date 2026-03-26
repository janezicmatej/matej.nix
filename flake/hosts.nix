{ inputs, self, ... }:

let
  inherit (inputs) nixpkgs;
  my-lib = import ../lib { inherit (nixpkgs) lib; };

  mkHost = my-lib.mkHost {
    inherit nixpkgs inputs;
    overlays = [ self.overlays.default ];
  };
in
{
  flake.nixosConfigurations = {
    fw16 = mkHost "fw16" {
      system = "x86_64-linux";
      user = "matej";
      features = [
        "openssh"
        "localisation"
        "gnupg"
        "shell"
        "desktop"
        "sway"
        "greeter"
        "printing"
        "networkmanager"
        "docker"
        "tailscale"
        "nix-ld"
        "yubikey"
        "calibre"
        "steam"
        "neovim"
        "dev"
        "claude"
      ];
    };

    tower = mkHost "tower" {
      system = "x86_64-linux";
      user = "matej";
      features = [
        "openssh"
        "localisation"
        "gnupg"
        "shell"
        "desktop"
        "sway"
        "greeter"
        "printing"
        "networkmanager"
        "docker"
        "tailscale"
        "nix-ld"
        "yubikey"
        "calibre"
        "steam"
        "initrd-ssh"
        "neovim"
        "dev"
        "claude"
      ];
    };

    # nixos-rebuild build-image --image-variant install-iso --flake .#iso
    iso = mkHost "iso" {
      system = "x86_64-linux";
      features = [
        "openssh"
      ];
    };

    ephvm = mkHost "ephvm" {
      system = "x86_64-linux";
      user = "matej";
      features = [
        "openssh"
        "localisation"
        "gnupg"
        "shell"
        "vm-guest"
        "vm-9p-automount"
        "docker"
        "neovim"
      ];
    };
  };
}
