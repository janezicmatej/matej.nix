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

echo "fetching latest tag..."
LATEST=$(curl -sf "https://api.github.com/repos/tkw1536/ggman/tags?per_page=1" | jq -r '.[0].name')
CURRENT=$(grep 'version = ' "$PKG_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [[ "$CURRENT" == "$LATEST" ]]; then
  echo "ggman already at $LATEST"
  exit 0
fi

echo "updating ggman: $CURRENT -> $LATEST"

echo "  prefetching source..."
BASE32=$(nix-prefetch-url --unpack "https://github.com/tkw1536/ggman/archive/${LATEST}.tar.gz" 2>/dev/null)
SRC_HASH=$(nix hash convert --to sri "sha256:$BASE32")
echo "  source: $SRC_HASH"

echo "  computing vendor hash..."
BUILD_OUTPUT=$(nix build --no-link --impure --expr "
  let
    pkgs = (builtins.getFlake \"path:$ROOT_DIR\").inputs.nixpkgs-master.legacyPackages.\${builtins.currentSystem};
  in (pkgs.buildGoModule.override { go = pkgs.go_1_26; } {
    pname = \"ggman\";
    version = \"$LATEST\";
    src = pkgs.fetchFromGitHub {
      owner = \"tkw1536\";
      repo = \"ggman\";
      rev = \"$LATEST\";
      hash = \"$SRC_HASH\";
    };
    vendorHash = \"\";
  }).goModules
" 2>&1) || true
VENDOR_HASH=$(echo "$BUILD_OUTPUT" | extract_hash) || true

if [[ -z "$VENDOR_HASH" ]]; then
  echo "  error: failed to compute vendor hash"
  echo "$BUILD_OUTPUT"
  exit 1
fi
echo "  vendor: $VENDOR_HASH"

OLD_SRC=$(grep 'sha256 = ' "$PKG_FILE" | grep -oP 'sha256-[A-Za-z0-9+/]+=')
OLD_VENDOR=$(grep 'vendorHash = ' "$PKG_FILE" | grep -oP 'sha256-[A-Za-z0-9+/]+=')

sed -i "s|version = \"$CURRENT\"|version = \"$LATEST\"|" "$PKG_FILE"
sed -i "s|$OLD_SRC|$SRC_HASH|" "$PKG_FILE"
sed -i "s|$OLD_VENDOR|$VENDOR_HASH|" "$PKG_FILE"

echo "ggman updated to $LATEST"
