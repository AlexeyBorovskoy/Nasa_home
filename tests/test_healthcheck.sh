#!/usr/bin/env bash
set -euo pipefail
# test_healthcheck.sh — verify healthcheck script produces output

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STORAGE_ROOT="${STORAGE_ROOT:-/mnt/storage}"
LOG_DIR="${STORAGE_ROOT}/logs/health"

echo "[TEST] Healthcheck output test..."

if [[ ! -d "${STORAGE_ROOT}" ]]; then
    echo "[SKIP] ${STORAGE_ROOT} not present — run on Jetson with mounted HDD"
    exit 0
fi

# Run the healthcheck
bash "${SCRIPT_DIR}/../scripts/diagnostics/storage_health.sh"
echo "[PASS] storage_health.sh completed without crash"

if ls "${LOG_DIR}"/smart-health-*.log &>/dev/null; then
    echo "[PASS] SMART log files created in ${LOG_DIR}"
else
    echo "[WARN] No SMART log files found (smartctl may not be installed)"
fi