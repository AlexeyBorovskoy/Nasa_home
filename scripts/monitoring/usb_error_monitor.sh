#!/usr/bin/env bash
# usb_error_monitor.sh — реал-тайм монитор ошибок USB (error -71 / RTL9210B-CG)
#
# Слушает dmesg в режиме watch. При первом появлении error -71:
#   1. Отправляет Telegram-алерт (до того как Docker упадёт)
#   2. Записывает событие в лог
#   3. Запускает watchdog немедленно (не ждать 3 мин)
#
# Запускается: systemd (nasa-usb-monitor.service) как persistent daemon

set -euo pipefail

LOG_TAG="nasa-usb-monitor"
SSD_DEV="/dev/sda"
ALERT_COOLDOWN_SECS=300  # не спамить Telegram чаще раз в 5 мин
LAST_ALERT=0

TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"
HOSTNAME_SHORT="$(hostname -s)"

log()  { echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]  $*" | systemd-cat -t "$LOG_TAG" -p info;  echo "$*" >&2; }
warn() { echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN]  $*" | systemd-cat -t "$LOG_TAG" -p warning; echo "$*" >&2; }

tg_send() {
    local msg="$1"
    [[ -z "$TELEGRAM_BOT_TOKEN" || -z "$TELEGRAM_CHAT_ID" ]] && return 0
    local now
    now=$(date +%s)
    if (( now - LAST_ALERT < ALERT_COOLDOWN_SECS )); then
        return 0
    fi
    LAST_ALERT=$now
    curl -sf --max-time 10 \
        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=[${HOSTNAME_SHORT}] ${msg}" \
        -d "parse_mode=HTML" > /dev/null || true
}

trigger_watchdog() {
    # Запускаем watchdog немедленно не дожидаясь следующего срабатывания таймера
    systemctl start nasa-usb-watchdog.service 2>/dev/null || true
}

log "USB error monitor started. Watching dmesg for error -71 on 1-2.2..."

# Читаем dmesg в режиме follow
dmesg --follow --decode 2>/dev/null | while IFS= read -r line; do
    # Смотрим на USB error -71 на нашем устройстве (1-2.2 = port 2 of hub 1-2)
    if echo "$line" | grep -qE "usb 1-2\.2.*error -71|1-2-port2.*unable to enum"; then
        warn "USB ERROR DETECTED: $line"
        tg_send "⚠️ USB SSD error -71 обнаружен (RTL9210B-CG). Docker может упасть. Запускаю watchdog..."
        trigger_watchdog
    fi

    # Также мониторим успешную энумерацию (SSD вернулся)
    if echo "$line" | grep -qE "usb 1-2\.2.*New USB device found.*9210"; then
        log "RTL9210B-CG enumerated: $line"
        tg_send "✅ USB SSD (RTL9210B-CG) переподключился"
    fi
done

log "dmesg follow exited — restarting..."
exit 1  # systemd перезапустит при RestartAlways
