#!/usr/bin/env bash
set -euo pipefail

KEY_DIR="/etc/secrets/initrd"

main() {
	echo "generating initrd SSH host keys in $KEY_DIR"
	sudo mkdir -p "$KEY_DIR"

	local key_type
	for key_type in rsa ed25519; do
		local key_file="$KEY_DIR/ssh_host_${key_type}_key"
		if [[ ! -f "$key_file" ]]; then
			sudo ssh-keygen -t "$key_type" -N "" -f "$key_file"
			echo "generated: $key_file"
		else
			echo "exists: $key_file"
		fi
	done

	echo "done. now run nixos-rebuild."
}

main "$@"
