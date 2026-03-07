#!/usr/bin/env bash
set -euo pipefail

SSH_PORT=2222
MEMORY=8G
CPUS=4
MOUNTS=()
CLAUDE_DIR=""
CLAUDE_JSON=""
IMAGE=""

usage() {
  cat <<EOF
Usage: ephvm-run.sh <image.qcow2> [options]

Options:
  --mount <path>       Mount host directory into VM (repeatable)
  --claude <path>      Mount claude config dir writable into VM
  --claude-json <path> Copy claude.json into mounted claude dir
  --memory <size>      VM memory (default: 8G)
  --cpus <n>         VM CPUs (default: 4)
  --ssh-port <port>  SSH port forward (default: 2222)
EOF
  exit 1
}

[ "${1:-}" ] || usage

IMAGE="$1"
shift

while [ $# -gt 0 ]; do
  case "$1" in
    --mount)      MOUNTS+=("$2"); shift 2 ;;
    --claude)     CLAUDE_DIR="$2"; shift 2 ;;
    --claude-json) CLAUDE_JSON="$2"; shift 2 ;;
    --memory)     MEMORY="$2"; shift 2 ;;
    --cpus)     CPUS="$2"; shift 2 ;;
    --ssh-port) SSH_PORT="$2"; shift 2 ;;
    *)          echo "unknown option: $1"; usage ;;
  esac
done

if [ ! -f "$IMAGE" ]; then
  echo "error: image not found: $IMAGE"
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
  QEMU_ARGS+=(
    -virtfs "local,path=$mount_path,mount_tag=mount_$name,security_model=none,id=fs${FS_ID}"
  )
  FS_ID=$((FS_ID + 1))
done

if [ -n "$CLAUDE_DIR" ]; then
  CLAUDE_DIR=$(realpath "$CLAUDE_DIR")
  QEMU_ARGS+=(
    -virtfs "local,path=$CLAUDE_DIR,mount_tag=claude,security_model=none,id=fs${FS_ID}"
  )
fi

if [ -n "$CLAUDE_JSON" ]; then
  QEMU_ARGS+=(-fw_cfg "name=opt/claude.json,file=$CLAUDE_JSON")
fi

exec "${QEMU_ARGS[@]}"
