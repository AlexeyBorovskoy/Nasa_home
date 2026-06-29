#!/usr/bin/env bash
set -euo pipefail
# test_mount.sh — verify storage mount point

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../config/.env"
[[ -f "${ENV_FILE}" ]] && source "${ENV_FILE}"
STORAGE_ROOT="${STORAGE_ROOT:-/mnt/storage}"

echo "[TEST] Storage mount check: ${STORAGE_ROOT}"

if mountpoint -q "${STORAGE_ROOT}"; then
    echo "[PASS] ${STORAGE_ROOT} is mounted"
    findmnt "${STORAGE_ROOT}" --output TARGET,SOURCE,FSTYPE,OPTIONS
else
    echo "[FAIL] ${STORAGE_ROOT} is NOT mounted"
    echo "  Run: sudo mount -a"
    exit 1
fi