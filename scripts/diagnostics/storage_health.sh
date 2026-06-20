#!/usr/bin/env bash
set -euo pipefail
DISK="${1:-/dev/sda}"
df -h /mnt/storage || true
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL,SERIAL || true
sudo smartctl -a "$DISK" || sudo smartctl -a -d sat "$DISK" || true
sudo dmesg | grep -i -E "error|reset|fail|i/o" | tail -n 100 || true
