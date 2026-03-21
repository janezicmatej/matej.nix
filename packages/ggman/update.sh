#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-prefetch
# shellcheck shell=bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_FILE="$SCRIPT_DIR/package.nix"

cd "$ROOT_DIR"

extract_hash() {
	sed 's/\x1b\[[0-9;]*m//g' | grep 'got:' | tail -1 | grep -oP 'sha256-[A-Za-z0-9+/]+='
}

main() {
	echo "fetching latest tag..."
	local latest current
	latest=$(curl -sf "https://api.github.com/repos/tkw1536/ggman/tags?per_page=1" | jq -r '.[0].name')
	current=$(grep 'version = ' "$PKG_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')

	if [[ "$current" == "$latest" ]]; then
		echo "ggman already at $latest"
		return 0
	fi

	echo "updating ggman: $current -> $latest"

	echo "  prefetching source..."
	local base32 src_hash
	base32=$(nix-prefetch-url --unpack "https://github.com/tkw1536/ggman/archive/${latest}.tar.gz" 2>/dev/null)
	src_hash=$(nix hash convert --to sri "sha256:$base32")
	echo "  source: $src_hash"

	echo "  computing vendor hash..."
	local build_output vendor_hash
	build_output=$(nix build --no-link --impure --expr "
    let
      pkgs = (builtins.getFlake \"path:$ROOT_DIR\").inputs.nixpkgs-master.legacyPackages.\${builtins.currentSystem};
    in (pkgs.buildGoModule.override { go = pkgs.go_1_26; } {
      pname = \"ggman\";
      version = \"$latest\";
      src = pkgs.fetchFromGitHub {
        owner = \"tkw1536\";
        repo = \"ggman\";
        rev = \"$latest\";
        hash = \"$src_hash\";
      };
      vendorHash = \"\";
    }).goModules
  " 2>&1) || true
	vendor_hash=$(echo "$build_output" | extract_hash) || true

	if [[ -z "$vendor_hash" ]]; then
		echo "error: failed to compute vendor hash" >&2
		echo "$build_output" >&2
		exit 1
	fi
	echo "  vendor: $vendor_hash"

	local old_src old_vendor
	old_src=$(grep 'sha256 = ' "$PKG_FILE" | grep -oP 'sha256-[A-Za-z0-9+/]+=')
	old_vendor=$(grep 'vendorHash = ' "$PKG_FILE" | grep -oP 'sha256-[A-Za-z0-9+/]+=')

	sed -i "s|version = \"$current\"|version = \"$latest\"|" "$PKG_FILE"
	sed -i "s|$old_src|$src_hash|" "$PKG_FILE"
	sed -i "s|$old_vendor|$vendor_hash|" "$PKG_FILE"

	echo "ggman updated to $latest"
}

main "$@"
