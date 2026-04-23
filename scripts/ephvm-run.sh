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
CLEANUP_TMPDIR=""
QEMU_PID=""
VM_READY=false
cleanup() {
	[ -n "$QEMU_PID" ] && kill "$QEMU_PID" 2>/dev/null && wait "$QEMU_PID" 2>/dev/null
	[ -n "$CLEANUP_OVERLAY" ] && rm -rf "$CLEANUP_OVERLAY"
	# preserve tmpdir on abnormal exit so the qemu log survives for inspection
	if [ -n "$CLEANUP_TMPDIR" ]; then
		if [ "$VM_READY" = true ]; then
			rm -rf "$CLEANUP_TMPDIR"
		else
			echo "qemu log preserved: $CLEANUP_TMPDIR/qemu.log" >&2
		fi
	fi
	return 0
}
trap cleanup EXIT

# returns 0 once the guest's sshd is speaking (first bytes are "SSH-")
awaiting_ssh_banner() {
	local port="$1"
	local banner
	banner=$(timeout 2 bash -c "exec 3<>/dev/tcp/localhost/$port; head -c 4 <&3" 2>/dev/null) || return 1
	[ "$banner" = "SSH-" ]
}

usage() {
	cat <<EOF
Usage: ephvm-run.sh [options]

Options:
  --mount <path>       Mount host directory into VM (repeatable)
  --no-claude          Skip mounting claude config dir
  --disk-size <size>   Resize guest disk (e.g. 50G)
  --memory <size>      VM memory (default: 4G)
  --cpus <n>           VM CPUs (default: 2)
  --ssh-port <port>    Use specific SSH port (default: auto)
  --serial             Attach to serial console instead of SSH
  -h, --help           Show usage
EOF
	exit "${1:-0}"
}

main() {
	setup_colors

	[ "$EUID" -eq 0 ] && die "ephvm-run.sh must not run as root"

	local ssh_port="" memory=4G cpus=2 claude=true disk_size="" serial=false
	local -a mounts=()

	while [ $# -gt 0 ]; do
		case "$1" in
		--mount)
			mounts+=("$2")
			shift 2
			;;
		--no-claude)
			claude=false
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
		--serial)
			serial=true
			shift
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
	[ -n "${EPHVM_FLAKE:-}" ] || die "EPHVM_FLAKE must be set to the flake directory"
	local flake="$EPHVM_FLAKE"
	image_dir=$(nix build --no-link --print-out-paths "${flake}#nixosConfigurations.ephvm.config.system.build.images.qemu")
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

	command -v qemu-system-x86_64 &>/dev/null || die "qemu-system-x86_64 not found"

	local accel="tcg"
	[ -r /dev/kvm ] && accel="kvm"

	# auto-allocate ssh port unless serial mode
	if [ "$serial" = false ] && [ -z "$ssh_port" ]; then
		ssh_port=10022
		while ss -tln | grep -q ":${ssh_port}\b"; do
			ssh_port=$((ssh_port + 1))
		done
	fi

	local nic_arg="user"
	if [ -n "$ssh_port" ]; then
		nic_arg="user,hostfwd=tcp:127.0.0.1:${ssh_port}-:22"
	fi

	local -a qemu_args=(
		qemu-system-x86_64
		-accel "$accel"
		-m "$memory"
		-smp "$cpus"
		-drive "$drive_arg"
		-nic "$nic_arg"
		-nographic
		-sandbox "on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny"
	)

	if [ "$accel" != "tcg" ]; then
		qemu_args+=(-cpu host)
	fi

	local fs_id=0 mount_path name tag
	for mount_path in "${mounts[@]}"; do
		[ -e "$mount_path" ] || die "--mount path does not exist: $mount_path"
		mount_path=$(realpath "$mount_path")
		# qemu parses -virtfs as csv, a comma in the path would inject options
		case "$mount_path" in
		*,*) die "--mount path may not contain commas: $mount_path" ;;
		esac
		name=$(basename "$mount_path")
		tag="m_${name:0:29}"
		qemu_args+=(
			-virtfs "local,path=$mount_path,mount_tag=$tag,security_model=none,id=fs${fs_id}"
		)
		fs_id=$((fs_id + 1))
	done

	if [ "$claude" = true ]; then
		[ -n "${CLAUDE_CONFIG_DIR:-}" ] || die "CLAUDE_CONFIG_DIR must be set (use --no-claude to skip)"
		mkdir -p "$CLAUDE_CONFIG_DIR"
		local claude_dir
		claude_dir=$(realpath "$CLAUDE_CONFIG_DIR")
		case "$claude_dir" in
		*,*) die "claude config dir may not contain commas: $claude_dir" ;;
		esac

		qemu_args+=(
			-virtfs "local,path=$claude_dir,mount_tag=claude,security_model=none,id=fs${fs_id}"
		)
		fs_id=$((fs_id + 1))
	fi

	info "---"
	info "Accel: $accel"
	info "---"

	if [ "$serial" = true ]; then
		exec "${qemu_args[@]}"
	fi

	CLEANUP_TMPDIR=$(mktemp -d)
	local qemu_log="$CLEANUP_TMPDIR/qemu.log"

	# start qemu in background and auto-ssh
	"${qemu_args[@]}" &>"$qemu_log" &
	QEMU_PID=$!

	# throwaway ssh key (vm accepts any key via AuthorizedKeysCommand)
	local ssh_key="$CLEANUP_TMPDIR/id_ed25519"
	ssh-keygen -t ed25519 -f "$ssh_key" -N "" -q

	info "waiting for vm (port $ssh_port)..."
	local attempts=0
	# poll for the real SSH banner, not TCP accept: qemu's user-mode nic
	# accepts host-side the moment qemu starts, well before guest sshd is up
	while ! awaiting_ssh_banner "$ssh_port"; do
		attempts=$((attempts + 1))
		[ $attempts -gt 120 ] && die "vm did not become ready in 60s"
		kill -0 "$QEMU_PID" 2>/dev/null || die "qemu exited unexpectedly"
		sleep 0.5
	done
	VM_READY=true

	ssh -p "$ssh_port" -t \
		-i "$ssh_key" \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-o LogLevel=ERROR \
		matej@localhost
}

main "$@"
