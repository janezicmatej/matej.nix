#!/usr/bin/env bash
set -euo pipefail

KEY_DIR="/etc/secrets/initrd"

echo "Generating initrd SSH host keys in $KEY_DIR"

sudo mkdir -p "$KEY_DIR"

if [[ ! -f "$KEY_DIR/ssh_host_rsa_key" ]]; then
  sudo ssh-keygen -t rsa -N "" -f "$KEY_DIR/ssh_host_rsa_key"
  echo "Generated: $KEY_DIR/ssh_host_rsa_key"
else
  echo "Exists: $KEY_DIR/ssh_host_rsa_key"
fi

if [[ ! -f "$KEY_DIR/ssh_host_ed25519_key" ]]; then
  sudo ssh-keygen -t ed25519 -N "" -f "$KEY_DIR/ssh_host_ed25519_key"
  echo "Generated: $KEY_DIR/ssh_host_ed25519_key"
else
  echo "Exists: $KEY_DIR/ssh_host_ed25519_key"
fi

echo "Done. Now run nixos-rebuild."
