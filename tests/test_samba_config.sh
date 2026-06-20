#!/usr/bin/env bash
set -euo pipefail
# test_samba_config.sh — validate Samba configuration

echo "[TEST] Samba config validation..."

if command -v testparm &>/dev/null; then
    testparm -s /etc/samba/smb.conf >/dev/null 2>&1
    grep -q "^\[public\]" /etc/samba/smb.conf 2>/dev/null || \
    grep -q "^\[Public\]" /etc/samba/smb.conf 2>/dev/null
    echo "[PASS] smb.conf valid, [Public] share present"
elif command -v docker &>/dev/null; then
    docker inspect homecloud_samba &>/dev/null
    echo "[PASS] Docker Samba container exists"
else
    echo "[SKIP] Neither testparm nor docker available — run on Jetson"
fi