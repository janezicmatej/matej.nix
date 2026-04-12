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
        "bootloader"
        "claude"
        "desktop"
        "dev"
        "direnv"
        "docker"
        "gaming"
        "git"
        "gnupg"
        "localisation"
        "neovim"
        "networkmanager"
        "nix-ld"
        "nix-settings"
        "onepassword"
        "openssh"
        "power"
        "printing"
        "shell"
        "sway"
        "tailscale"
        "udev"
        "zsh"
      ];
    };

    tower = mkHost "tower" {
      system = "x86_64-linux";
      user = "matej";
      features = [
        "bootloader"
        "claude"
        "desktop"
        "dev"
        "direnv"
        "docker"
        "gaming"
        "git"
        "gnupg"
        "harmonia"
        "initrd-ssh"
        "localisation"
        "neovim"
        "networkmanager"
        "nix-ld"
        "nix-settings"
        "onepassword"
        "openssh"
        "printing"
        "shell"
        "sway"
        "tailscale"
        "udev"
        "zsh"
      ];
    };

    # nixos-rebuild build-image --image-variant install-iso --flake .#iso
    iso = mkHost "iso" {
      system = "x86_64-linux";
      user = "matej";
      features = [
        "nix-settings"
        "openssh"
        "zsh"
      ];
    };

    cube = mkHost "cube" {
      system = "x86_64-linux";
      user = "matej";
      features = [
        "bootloader"
        "localisation"
        "nix-settings"
        "openssh"
        "remote-base"
        "shell"
        "tailscale"
        "zsh"
      ];
    };

    # nix run github:nix-community/nixos-anywhere -- --flake .#floo root@<ip>
    floo = mkHost "floo" {
      system = "x86_64-linux";
      user = "matej";
      features = [
        "filedrop"
        "localisation"
        "nix-settings"
        "openssh"
        "remote-base"
        "shell"
        "tailscale"
        "zsh"
      ];
    };

    fortress = mkHost "fortress" {
      system = "x86_64-linux";
      user = "matej";
      features = [
        "bootloader"
        "desktop"
        "gnupg"
        "localisation"
        "networkmanager"
        "nix-settings"
        "sway"
        "udev"
        "zsh"
      ];
    };

    ephvm = mkHost "ephvm" {
      system = "x86_64-linux";
      user = "matej";
      features = [
        "claude"
        "dev"
        "docker"
        "git"
        "gnupg"
        "localisation"
        "neovim"
        "nix-settings"
        "openssh"
        "shell"
        "vm-guest"
        "zsh"
      ];
    };
  };
}
