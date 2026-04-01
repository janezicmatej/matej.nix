# shellcheck shell=bash
# composable nix devshell from matej.nix
# usage in .envrc: use dev uv_14 pg_18

# generates a flake and delegates to use_flake at the calling scope
use_dev() {
	local nix_list=""
	for c in "$@"; do
		if [[ ! "$c" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
			log_error "use_dev: invalid component name: $c"
			return 1
		fi
		nix_list="$nix_list \"$c\""
	done

	local system
	case "$(uname -s)-$(uname -m)" in
	Linux-x86_64) system="x86_64-linux" ;;
	Linux-aarch64) system="aarch64-linux" ;;
	Darwin-x86_64) system="x86_64-darwin" ;;
	Darwin-arm64) system="aarch64-darwin" ;;
	esac

	if [[ -z "$system" ]]; then
		log_error "use_dev: unsupported platform: $(uname -s)-$(uname -m)"
		return 1
	fi

	local dev_path nixpkgs_path registry_filter
	# shellcheck disable=SC2016 # $id is a jq variable, not shell
	registry_filter='.flakes[] | select(.from.id == $id) | .to.path'

	local registry_file="${XDG_CONFIG_HOME:-$HOME/.config}/nix/registry.json"
	if [[ ! -f "$registry_file" ]]; then
		registry_file="/etc/nix/registry.json"
	fi

	dev_path="$(jq -re --arg id dev "$registry_filter" "$registry_file" 2>/dev/null)"
	nixpkgs_path="$(jq -re --arg id nixpkgs "$registry_filter" "$registry_file" 2>/dev/null)"

	if [[ -z "$dev_path" ]]; then
		log_error "use_dev: 'dev' not found in nix registry"
		return 1
	fi
	if [[ -z "$nixpkgs_path" ]]; then
		log_error "use_dev: 'nixpkgs' not found in nix registry"
		return 1
	fi

	local components_hash project_hash cache_dir
	components_hash="$(sha256sum "$dev_path/flake/dev-components.nix" 2>/dev/null | cut -c1-16)"
	project_hash="$(echo "$PWD" | sha256sum | cut -c1-16)"
	cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dev-flakes/$project_hash"
	mkdir -p "$cache_dir"

	cat >"$cache_dir/flake.nix.tmp" <<DEVFLAKE
# dev-components: $components_hash
{
  inputs.dev = { url = "path:${dev_path}"; flake = false; };
  inputs.nixpkgs.url = "path:${nixpkgs_path}";
  outputs = { dev, nixpkgs, ... }:
    let
      system = "${system}";
      pkgs = nixpkgs.legacyPackages.\${system};
      devLib = import "\${dev}/flake/dev-components.nix" { inherit pkgs; lib = nixpkgs.lib; };
    in {
      devShells.\${system}.default = devLib.mkComponentShell [$nix_list ];
    };
}
DEVFLAKE

	if ! cmp -s "$cache_dir/flake.nix.tmp" "$cache_dir/flake.nix" 2>/dev/null; then
		mv "$cache_dir/flake.nix.tmp" "$cache_dir/flake.nix"
		rm -f "$cache_dir/flake.lock"
	else
		rm "$cache_dir/flake.nix.tmp"
	fi

	use_flake "path:$cache_dir"
}
