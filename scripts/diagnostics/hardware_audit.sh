#!/usr/bin/env bash
set -euo pipefail
OUT_DIR="${1:-./runtime/audit}"
mkdir -p "$OUT_DIR"
OUT="$OUT_DIR/HARDWARE_AUDIT_REPORT.md"
{
  echo "# Hardware Audit Report"
  echo
  echo "Generated: $(date -Is)"
  echo
  echo "## uname"
  echo '```'
  uname -a || true
  echo '```'
  echo "## os-release"
  echo '```'
  cat /etc/os-release || true
  echo '```'
  echo "## RAM"
  echo '```'
  free -h || true
  echo '```'
  echo "## Filesystems"
  echo '```'
  df -h || true
  echo '```'
  echo "## Block devices"
  echo '```'
  lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL,SERIAL || true
  echo '```'
  echo "## USB"
  echo '```'
  lsusb || true
  echo '```'
  echo "## IP"
  echo '```'
  ip a || true
  ip route || true
  echo '```'
  echo "## dmesg errors"
  echo '```'
  sudo dmesg | grep -i -E "usb|sd|error|reset|fail|i/o" | tail -n 200 || true
  echo '```'
} > "$OUT"
echo "Wrote $OUT"
