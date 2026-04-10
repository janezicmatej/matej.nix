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
        "gaming"
        "direnv"
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
        "gaming"
        "initrd-ssh"
        "direnv"
        "neovim"
        "dev"
        "claude"
        "harmonia"
      ];
    };

    # nixos-rebuild build-image --image-variant install-iso --flake .#iso
    iso = mkHost "iso" {
      system = "x86_64-linux";
      user = "matej";
      features = [
        "openssh"
      ];
    };

    cube = mkHost "cube" {
      system = "x86_64-linux";
      user = "matej";
      features = [
        "openssh"
        "localisation"
        "shell"
        "tailscale"
        "remote-base"
      ];
    };

    # nix run github:nix-community/nixos-anywhere -- --flake .#floo root@<ip>
    floo = mkHost "floo" {
      system = "x86_64-linux";
      user = "matej";
      features = [
        "openssh"
        "localisation"
        "shell"
        "tailscale"
        "remote-base"
        "filedrop"
      ];
    };

    fortress = mkHost "fortress" {
      system = "x86_64-linux";
      user = "matej";
      features = [
        "localisation"
        "gnupg"
        "shell-minimal"
        "desktop-minimal"
        "sway"
        "greeter"
        "networkmanager"
        "yubikey"
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
        "claude"
        "dev"
      ];
    };
  };
}
