#!/usr/bin/env bash
# NASA Home Cloud — send daily report to Telegram via VPS relay
# Jetson cannot reach api.telegram.org directly; we pipe the report
# over SSH to VPS which has unrestricted internet access.
set -euo pipefail

CONF="/etc/nasa-monitor/telegram.env"
REPORT_CMD="/usr/local/sbin/nasa-daily-report.sh"
LOG_DIR="/var/log/nasa-monitor"
REPORT_FILE="${LOG_DIR}/last-report.txt"
SEND_LOG="${LOG_DIR}/last-telegram-send.json"
VPS_HOST="${VPS_HOST:-193.8.215.130}"
VPS_USER="${VPS_USER:-root}"
VPS_KEY="${VPS_KEY:-/home/admin/.ssh/id_ed25519}"

mkdir -p "$LOG_DIR"

if [ ! -f "$CONF" ]; then
    echo "ERROR: $CONF not found"
    exit 1
fi

. "$CONF"

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${TELEGRAM_CHAT_ID:-}" ]; then
    echo "ERROR: TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID is empty"
    exit 1
fi

if [ ! -x "$REPORT_CMD" ]; then
    echo "ERROR: $REPORT_CMD not found or not executable"
    exit 1
fi

"$REPORT_CMD" > "$REPORT_FILE"

# Send via VPS: pipe report text over SSH, VPS runs curl to Telegram
ssh -i "$VPS_KEY" \
    -o StrictHostKeyChecking=no \
    -o ConnectTimeout=15 \
    -o BatchMode=yes \
    "${VPS_USER}@${VPS_HOST}" \
    "curl -sS -X POST 'https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage' \
        -d 'chat_id=${TELEGRAM_CHAT_ID}' \
        --data-urlencode 'text@-'" \
    < "$REPORT_FILE" \
    | tee "$SEND_LOG" \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print('OK, message_id=' + str(d['result']['message_id']) if d.get('ok') else 'FAIL: '+str(d))"
