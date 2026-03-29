[private]
default:
    @just --list

# rebuild and switch
switch config="":
    nixos-rebuild switch --flake .{{ if config != "" { "#" + config } else { "" } }} --sudo

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
    nixos-rebuild build-image --image-variant iso-installer --flake .#iso

# run ephemeral VM
ephvm *ARGS:
    bash scripts/ephvm-run.sh {{ARGS}}

# ssh into running ephemeral VM
ephvm-ssh port="2222":
    ssh -p {{port}} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null matej@localhost

# provision a host with nixos-anywhere
provision host ip:
    #!/usr/bin/env bash
    set -euo pipefail
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT
    install -d -m 755 "$tmpdir/etc/ssh"
    ssh-keygen -t ed25519 -f "$tmpdir/etc/ssh/ssh_host_ed25519_key" -N ""
    age_key=$(ssh-to-age < "$tmpdir/etc/ssh/ssh_host_ed25519_key.pub")
    echo "age key: $age_key"
    echo "add this key to .sops.yaml, re-encrypt secrets, then press enter to continue"
    read -r
    nix run github:nix-community/nixos-anywhere -- --no-reboot --flake .#{{host}} --extra-files "$tmpdir" --generate-hardware-config nixos-generate-config ./hosts/{{host}}/hardware-configuration.nix root@{{ip}}
    echo "remove USB and press enter to reboot"
    read -r
    ssh root@{{ip}} reboot

# deploy config to a remote host
deploy host remote=host:
    nixos-rebuild switch --flake .#{{host}} --target-host {{remote}} --sudo --ask-sudo-password

# garbage collect old generations
clean:
    sudo nix-collect-garbage $(nix eval --raw -f ./nix.nix nix.gc.options)
