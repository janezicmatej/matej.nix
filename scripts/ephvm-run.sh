#!/usr/bin/env bash
set -euo pipefail

SSH_PORT=2222
MEMORY=8G
CPUS=4
MOUNTS=()
CLAUDE=false

usage() {
  cat <<EOF
Usage: ephvm-run.sh [options]

Options:
  --mount <path>       Mount host directory into VM (repeatable)
  --claude             Mount claude config dir (requires CLAUDE_CONFIG_DIR)
  --memory <size>      VM memory (default: 8G)
  --cpus <n>           VM CPUs (default: 4)
  --ssh-port <port>    SSH port forward (default: 2222)
EOF
  exit 1
}

while [ $# -gt 0 ]; do
  case "$1" in
    --mount)      MOUNTS+=("$2"); shift 2 ;;
    --claude)     CLAUDE=true; shift ;;
    --memory)     MEMORY="$2"; shift 2 ;;
    --cpus)       CPUS="$2"; shift 2 ;;
    --ssh-port)   SSH_PORT="$2"; shift 2 ;;
    -h|--help)    usage ;;
    *)            echo "unknown option: $1"; usage ;;
  esac
done

echo "building ephvm image..."
IMAGE_DIR=$(nix build --no-link --print-out-paths .#nixosConfigurations.ephvm.config.system.build.images.qemu)
IMAGE=$(find "$IMAGE_DIR" -name '*.qcow2' -print -quit)

if [ -z "$IMAGE" ]; then
  echo "error: no qcow2 image found in $IMAGE_DIR"
  exit 1
fi

ACCEL="tcg"
[ -r /dev/kvm ] && ACCEL="kvm"

QEMU_ARGS=(
  qemu-system-x86_64
  -accel "$ACCEL"
  -m "$MEMORY"
  -smp "$CPUS"
  -drive "file=$IMAGE,format=qcow2,snapshot=on"
  -nic "user,hostfwd=tcp::${SSH_PORT}-:22"
  -nographic
)

if [ "$ACCEL" != "tcg" ]; then
  QEMU_ARGS+=(-cpu host)
fi

FS_ID=0
for mount_path in "${MOUNTS[@]}"; do
  mount_path=$(realpath "$mount_path")
  name=$(basename "$mount_path")
  tag="m_${name:0:29}"
  QEMU_ARGS+=(
    -virtfs "local,path=$mount_path,mount_tag=$tag,security_model=none,id=fs${FS_ID}"
  )
  FS_ID=$((FS_ID + 1))
done

if [ "$CLAUDE" = true ]; then
  if [ -z "${CLAUDE_CONFIG_DIR:-}" ]; then
    echo "error: --claude requires CLAUDE_CONFIG_DIR to be set"
    exit 1
  fi
  mkdir -p "$CLAUDE_CONFIG_DIR"
  claude_dir=$(realpath "$CLAUDE_CONFIG_DIR")

  QEMU_ARGS+=(
    -virtfs "local,path=$claude_dir,mount_tag=claude,security_model=none,id=fs${FS_ID}"
  )
  FS_ID=$((FS_ID + 1))
fi

exec "${QEMU_ARGS[@]}"
