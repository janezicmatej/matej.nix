#!/usr/bin/env bash
set -uo pipefail

build() {
	local name="$1" ref="$2" link="$3"
	echo "building $name..." >&2
	if nix build "$ref" --out-link "$link"; then
		return 0
	else
		echo "FAILED: $name" >&2
		return 1
	fi
}

main() {
	mkdir -p "$GC_ROOT_DIR"
	local failed=0

	for host in $HOSTS; do
		build "$host" \
			"$FLAKE_REF#nixosConfigurations.$host.config.system.build.toplevel" \
			"$GC_ROOT_DIR/$host" || failed=1
	done

	build "ephvm-image" \
		"$FLAKE_REF#nixosConfigurations.ephvm.config.system.build.images.qemu" \
		"$GC_ROOT_DIR/ephvm-image" || failed=1

	return $failed
}

main "$@"
