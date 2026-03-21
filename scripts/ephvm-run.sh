#!/usr/bin/env bash
set -euo pipefail

setup_colors() {
	if [ -t 2 ]; then
		red=$'\033[31m'
		yellow=$'\033[33m'
		cyan=$'\033[36m'
		reset=$'\033[0m'
	else
		red="" yellow="" cyan="" reset=""
	fi
}

die() {
	echo "${red}error:${reset} $*" >&2
	exit 1
}

warn() {
	echo "${yellow}warning:${reset} $*" >&2
}

info() {
	echo "${cyan}$*${reset}" >&2
}

# globals for cleanup trap
CLEANUP_OVERLAY=""
cleanup() {
	[ -n "$CLEANUP_OVERLAY" ] && rm -rf "$CLEANUP_OVERLAY"
	return 0
}
trap cleanup EXIT

usage() {
	cat <<EOF
Usage: ephvm-run.sh [options]

Options:
  --mount <path>       Mount host directory into VM (repeatable)
  --claude             Mount claude config dir (requires CLAUDE_CONFIG_DIR)
  --disk-size <size>   Resize guest disk (e.g. 50G)
  --memory <size>      VM memory (default: 8G)
  --cpus <n>           VM CPUs (default: 4)
  --ssh-port <port>    SSH port forward (default: 2222)
  -h, --help           Show usage
EOF
	exit "${1:-0}"
}

main() {
	setup_colors

	local ssh_port=2222 memory=8G cpus=4 claude=false disk_size=""
	local -a mounts=()

	while [ $# -gt 0 ]; do
		case "$1" in
		--mount)
			mounts+=("$2")
			shift 2
			;;
		--claude)
			claude=true
			shift
			;;
		--disk-size)
			disk_size="$2"
			shift 2
			;;
		--memory)
			memory="$2"
			shift 2
			;;
		--cpus)
			cpus="$2"
			shift 2
			;;
		--ssh-port)
			ssh_port="$2"
			shift 2
			;;
		-h | --help) usage ;;
		*)
			echo "${red}error:${reset} unknown option: $1" >&2
			usage 1
			;;
		esac
	done

	info "building ephvm image..."
	local image_dir image
	image_dir=$(nix build --no-link --print-out-paths .#nixosConfigurations.ephvm.config.system.build.images.qemu)
	image=$(find "$image_dir" -name '*.qcow2' -print -quit)
	[ -n "$image" ] || die "no qcow2 image found in $image_dir"

	# create resized overlay when --disk-size is given
	local drive_arg
	if [ -n "$disk_size" ]; then
		CLEANUP_OVERLAY=$(mktemp -d)
		local overlay="$CLEANUP_OVERLAY/overlay.qcow2"
		qemu-img create -f qcow2 -b "$(realpath "$image")" -F qcow2 "$overlay" "$disk_size"
		drive_arg="file=$overlay,format=qcow2"
	else
		drive_arg="file=$image,format=qcow2,snapshot=on"
	fi

	local accel="tcg"
	[ -r /dev/kvm ] && accel="kvm"

	local -a qemu_args=(
		qemu-system-x86_64
		-accel "$accel"
		-m "$memory"
		-smp "$cpus"
		-drive "$drive_arg"
		-nic "user,hostfwd=tcp::${ssh_port}-:22"
		-nographic
	)

	if [ "$accel" != "tcg" ]; then
		qemu_args+=(-cpu host)
	fi

	local fs_id=0 mount_path name tag
	for mount_path in "${mounts[@]}"; do
		mount_path=$(realpath "$mount_path")
		name=$(basename "$mount_path")
		tag="m_${name:0:29}"
		qemu_args+=(
			-virtfs "local,path=$mount_path,mount_tag=$tag,security_model=none,id=fs${fs_id}"
		)
		fs_id=$((fs_id + 1))
	done

	if [ "$claude" = true ]; then
		[ -n "${CLAUDE_CONFIG_DIR:-}" ] || die "--claude requires CLAUDE_CONFIG_DIR to be set"
		mkdir -p "$CLAUDE_CONFIG_DIR"
		local claude_dir
		claude_dir=$(realpath "$CLAUDE_CONFIG_DIR")

		qemu_args+=(
			-virtfs "local,path=$claude_dir,mount_tag=claude,security_model=none,id=fs${fs_id}"
		)
		fs_id=$((fs_id + 1))
	fi

	info "---"
	info "Accel: $accel | SSH: ssh -p $ssh_port matej@localhost"
	info "---"

	exec "${qemu_args[@]}"
}

main "$@"
