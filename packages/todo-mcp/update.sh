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
	echo "fetching latest version..."
	local latest current
	latest=$(curl -sf "https://git.janezic.dev/api/v1/repos/janezicmatej/todo-mcp/tags?limit=1" | jq -r '.[0].name')
	current=$(grep 'version = ' "$PKG_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')

	if [[ "$current" == "$latest" ]]; then
		echo "todo-mcp already at $latest"
		return 0
	fi

	echo "updating todo-mcp: $current -> $latest"

	echo "  prefetching source..."
	local base32 src_hash
	base32=$(nix-prefetch-url --unpack "https://git.janezic.dev/janezicmatej/todo-mcp/archive/${latest}.tar.gz" 2>/dev/null)
	src_hash=$(nix hash convert --to sri "sha256:$base32")
	echo "  source: $src_hash"

	echo "  computing cargo hash..."
	local build_output cargo_hash
	build_output=$(nix build --no-link --impure --expr "
    let
      pkgs = (builtins.getFlake \"path:$ROOT_DIR\").inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
    in pkgs.rustPlatform.fetchCargoVendor {
      src = pkgs.fetchFromGitea {
        domain = \"git.janezic.dev\";
        owner = \"janezicmatej\";
        repo = \"todo-mcp\";
        rev = \"$latest\";
        hash = \"$src_hash\";
      };
      hash = \"\";
    }
  " 2>&1) || true
	cargo_hash=$(echo "$build_output" | extract_hash) || true

	if [[ -z "$cargo_hash" ]]; then
		echo "error: failed to compute cargo hash" >&2
		echo "$build_output" >&2
		exit 1
	fi
	echo "  cargo: $cargo_hash"

	local old_src old_cargo
	old_src=$(grep 'sha256 = ' "$PKG_FILE" | grep -oP 'sha256-[A-Za-z0-9+/]+=')
	old_cargo=$(grep 'cargoHash = ' "$PKG_FILE" | grep -oP 'sha256-[A-Za-z0-9+/]+=')

	sed -i "s|version = \"$current\"|version = \"$latest\"|" "$PKG_FILE"
	sed -i "s|$old_src|$src_hash|" "$PKG_FILE"
	sed -i "s|$old_cargo|$cargo_hash|" "$PKG_FILE"

	echo "todo-mcp updated to $latest"
}

main "$@"
