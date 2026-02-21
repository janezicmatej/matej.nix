[private]
default:
    @just --list

# rebuild and switch
switch:
    nixos-rebuild switch --flake . --sudo

# fetch flake inputs
sync:
    nix flake prefetch-inputs

# update flake inputs
update:
    nix flake update

# update flake inputs, rebuild and switch
bump: update switch

# build installation iso
iso:
    nixos-rebuild build-image --image-variant iso-installer --flake .#live-iso

# garbage collect old generations
clean:
    sudo nix-collect-garbage $(nix eval --raw -f ./nix.nix nix.gc.options)
