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

# update a package to latest version
update-package pkg:
    bash packages/{{pkg}}/update.sh

# update all packages with update scripts
update-package-all:
    @for script in packages/*/update.sh; do bash "$script"; done

# build all packages and hosts
build:
    nix flake check

# build installation iso
iso:
    nixos-rebuild build-image --image-variant iso-installer --flake .#live-iso

# garbage collect old generations
clean:
    sudo nix-collect-garbage $(nix eval --raw -f ./nix.nix nix.gc.options)
