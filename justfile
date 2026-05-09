[private]
default:
    @just --list

# rebuild the system
rebuild op="switch" host=`hostname`:
    nixos-rebuild {{op}} --flake .#{{host}} --sudo

# update flake inputs
update:
    nix flake update

# update all packages with update scripts
update-package:
    @for script in packages/*/update.sh; do bash "$script"; done

# build all packages and hosts
check:
    nix flake check

# build installation iso
iso:
    nixos-rebuild build-image --image-variant iso-installer --flake .#iso

# run ephemeral VM
ephvm *ARGS:
    bash scripts/ephvm-run.sh {{ARGS}}

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
deploy op="switch" host=`hostname` remote=host:
    nixos-rebuild {{op}} --flake .#{{host}} --target-host {{remote}} --sudo --ask-sudo-password

# garbage collect old generations
clean host=`hostname`:
    sudo nix-collect-garbage $(nix eval --raw .#nixosConfigurations.{{host}}.config.nix.gc.options)
