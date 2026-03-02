#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-prefetch
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_FILE="$SCRIPT_DIR/package.nix"

cd "$ROOT_DIR"

extract_hash() {
  sed 's/\x1b\[[0-9;]*m//g' | grep 'got:' | tail -1 | grep -oP 'sha256-[A-Za-z0-9+/]+='
}

echo "fetching latest version..."
LATEST=$(curl -sf "https://git.janezic.dev/api/v1/repos/janezicmatej/ahab/tags?limit=1" | jq -r '.[0].name')
CURRENT=$(grep 'version = ' "$PKG_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [[ "$CURRENT" == "$LATEST" ]]; then
  echo "ahab already at $LATEST"
  exit 0
fi

echo "updating ahab: $CURRENT -> $LATEST"

echo "  prefetching source..."
BASE32=$(nix-prefetch-url --unpack "https://git.janezic.dev/janezicmatej/ahab/archive/${LATEST}.tar.gz" 2>/dev/null)
SRC_HASH=$(nix hash convert --to sri "sha256:$BASE32")
echo "  source: $SRC_HASH"

echo "  computing cargo hash..."
BUILD_OUTPUT=$(nix build --no-link --impure --expr "
  let
    pkgs = (builtins.getFlake \"path:$ROOT_DIR\").inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
  in pkgs.rustPlatform.fetchCargoVendor {
    src = pkgs.fetchFromGitea {
      domain = \"git.janezic.dev\";
      owner = \"janezicmatej\";
      repo = \"ahab\";
      rev = \"$LATEST\";
      hash = \"$SRC_HASH\";
    };
    hash = \"\";
  }
" 2>&1) || true
CARGO_HASH=$(echo "$BUILD_OUTPUT" | extract_hash) || true

if [[ -z "$CARGO_HASH" ]]; then
  echo "  error: failed to compute cargo hash"
  echo "$BUILD_OUTPUT"
  exit 1
fi
echo "  cargo: $CARGO_HASH"

OLD_SRC=$(grep 'sha256 = ' "$PKG_FILE" | grep -oP 'sha256-[A-Za-z0-9+/]+=')
OLD_CARGO=$(grep 'cargoHash = ' "$PKG_FILE" | grep -oP 'sha256-[A-Za-z0-9+/]+=')

sed -i "s|version = \"$CURRENT\"|version = \"$LATEST\"|" "$PKG_FILE"
sed -i "s|$OLD_SRC|$SRC_HASH|" "$PKG_FILE"
sed -i "s|$OLD_CARGO|$CARGO_HASH|" "$PKG_FILE"

echo "ahab updated to $LATEST"
