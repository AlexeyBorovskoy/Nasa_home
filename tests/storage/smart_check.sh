#!/usr/bin/env bash
set -euo pipefail
# smart_check.sh -- read-only SMART health check for USB SSD
# NEVER runs destructive tests. Reports only.

SCRIPT_NAME="$(basename "$0")"
DEVICE=""
OUTPUT=""

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME --device <device_path> [OPTIONS]

Options:
  --device <dev>  Block device to check, e.g. /dev/sda (required)
  --output <file> Save Markdown report (optional)
  --help          Show this help

Note: Requires sudo / root to access SMART data.
      For USB-SATA bridges (RTL9210B-CG), smartctl may need -d sat or -d scsi.

Examples:
  sudo $SCRIPT_NAME --device /dev/sda
  sudo $SCRIPT_NAME --device /dev/sda --output /tmp/smart-report.md
EOF
}

check_deps() {
    if ! command -v smartctl >/dev/null 2>&1; then
        echo "ERROR: smartctl not found. Install: apt-get install smartmontools" >&2
        exit 2
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --device)  DEVICE="${2:-}"; shift 2 ;;
        --output)  OUTPUT="${2:-}"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *)         echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
done

if [[ -z "$DEVICE" ]]; then
    echo "ERROR: --device is required" >&2; usage >&2; exit 1
fi

if [[ ! -b "$DEVICE" ]]; then
    echo "ERROR: $DEVICE is not a block device or not present" >&2
    exit 1
fi

check_deps

TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
PASS=0
FAIL=0
WARN=0
REPORT_LINES=()

echo "=== NASA SMART Check: $DEVICE ($TIMESTAMP) ==="
echo ""

# Try direct access first, then with -d sat (USB bridge hint)
run_smartctl() {
    local args=("$@")
    smartctl "${args[@]}" "$DEVICE" 2>/dev/null || true
}

# 1. Overall health
echo "--- SMART Overall Health ---"
HEALTH_OUT="$(run_smartctl -H)"
echo "$HEALTH_OUT"

if echo "$HEALTH_OUT" | grep -qiE "PASSED|Health Status:.*OK"; then
    echo ""
    echo "PASS: SMART overall health PASSED"
    PASS=$((PASS + 1))
    REPORT_LINES+=("| SMART Health | PASS | PASSED |")
elif echo "$HEALTH_OUT" | grep -qiE "FAILED|Health Status:.*(FAIL|BAD)"; then
    echo ""
    echo "FAIL: SMART health FAILED -- drive may be failing"
    FAIL=$((FAIL + 1))
    REPORT_LINES+=("| SMART Health | FAIL | FAILED |")
elif echo "$HEALTH_OUT" | grep -qi "Unable to detect"; then
    echo ""
    echo "WARN: Could not detect device type via USB bridge"
    echo "Trying -d sat (USB SATA bridge)..."
    HEALTH_SAT="$(smartctl -d sat -H "$DEVICE" 2>/dev/null || true)"
    if echo "$HEALTH_SAT" | grep -qiE "PASSED|Health Status:.*OK"; then
        echo "PASS: SMART health PASSED (via -d sat)"
        PASS=$((PASS + 1))
        REPORT_LINES+=("| SMART Health | PASS | PASSED (via -d sat) |")
    else
        WARN=$((WARN + 1))
        REPORT_LINES+=("| SMART Health | WARN | USB bridge limited passthrough |")
    fi
else
    WARN=$((WARN + 1))
    REPORT_LINES+=("| SMART Health | WARN | Status unknown |")
fi

# 2. Temperature
echo ""
echo "--- Temperature ---"
TEMP_OUT="$(run_smartctl -a)"
TEMP="$(echo "$TEMP_OUT" | grep -i 'Temperature_Celsius\|Temperature:' | head -1 || echo "")"
if [[ -n "$TEMP" ]]; then
    TEMP_VAL="$(echo "$TEMP" | awk '{print $NF}')"
    echo "Temperature: ${TEMP_VAL}C"
    REPORT_LINES+=("| Temperature | INFO | ${TEMP_VAL}C |")
    if [[ "${TEMP_VAL}" -gt 55 ]] 2>/dev/null; then
        echo "WARN: Temperature ${TEMP_VAL}C is high (> 55C)"
        WARN=$((WARN + 1))
    fi
else
    echo "INFO: Temperature data not available via USB bridge"
    REPORT_LINES+=("| Temperature | INFO | not available via USB |")
fi

# 3. Self-test log (read-only)
echo ""
echo "--- Self-test Log ---"
SELFTEST_OUT="$(smartctl -l selftest "$DEVICE" 2>/dev/null || true)"
if echo "$SELFTEST_OUT" | grep -q "No self-tests have been logged"; then
    echo "INFO: No self-tests have been run"
    REPORT_LINES+=("| Self-test Log | INFO | No tests logged |")
elif echo "$SELFTEST_OUT" | grep -qiE "Completed without error|Successful"; then
    echo "PASS: Last self-test completed without error"
    PASS=$((PASS + 1))
    REPORT_LINES+=("| Self-test Log | PASS | Last test successful |")
elif echo "$SELFTEST_OUT" | grep -qi "Failed"; then
    echo "FAIL: Last self-test failed"
    FAIL=$((FAIL + 1))
    REPORT_LINES+=("| Self-test Log | FAIL | Last test failed |")
else
    echo "INFO: Self-test log: $SELFTEST_OUT" | head -5
    REPORT_LINES+=("| Self-test Log | INFO | see output |")
fi

echo ""
echo "=== Summary: PASS=$PASS  WARN=$WARN  FAIL=$FAIL ==="

if [[ -n "$OUTPUT" ]]; then
    {
        echo "# SMART Check Report"
        echo ""
        echo "**Date:** $TIMESTAMP"
        echo "**Device:** $DEVICE"
        echo ""
        echo "| Check | Result | Details |"
        echo "|---|---|---|"
        for line in "${REPORT_LINES[@]}"; do
            echo "$line"
        done
        echo ""
        echo "**Total:** PASS=$PASS  WARN=$WARN  FAIL=$FAIL"
        echo ""
        echo "## Raw SMART Output"
        echo '```'
        run_smartctl -a | head -60
        echo '```'
    } > "$OUTPUT"
    echo "Report saved: $OUTPUT"
fi

[[ "$FAIL" -gt 0 ]] && exit 1
[[ "$WARN" -gt 0 ]] && exit 2
exit 0
