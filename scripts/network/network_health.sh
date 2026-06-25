#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../../config/.env"

log() { echo "[$(date ''+%Y-%m-%d %H:%M:%S'')] $*"; }

if [[ -f "${ENV_FILE}" ]]; then
    source "${ENV_FILE}"
fi

GATEWAY_IP="${GATEWAY_IP:-192.168.0.1}"
LAN_INTERFACE="${LAN_INTERFACE:-eth0}"
LISTEN_PORTS=(22 8080 2283 8090)
ERRORS=0

log "=== Network health check started ==="

log "--- Interface: ${LAN_INTERFACE} ---"
operstate="$(cat "/sys/class/net/${LAN_INTERFACE}/operstate" 2>/dev/null || echo "unknown")"
if [[ "${operstate}" == "up" ]]; then
    ip_addr="$(ip -4 addr show "${LAN_INTERFACE}" 2>/dev/null | grep ''inet '' | awk ''{print $2}'' | head -1 || echo "not assigned")"
    log "OK  ${LAN_INTERFACE} is UP — IP: ${ip_addr}"
else
    log "CRITICAL: ${LAN_INTERFACE} is ${operstate}"
    ERRORS=$(( ERRORS + 1 ))
fi

echo ""
log "--- Gateway ping: ${GATEWAY_IP} ---"
if ping -c 2 -W 3 "${GATEWAY_IP}" &>/dev/null; then
    log "OK  Gateway ${GATEWAY_IP} reachable"
else
    log "WARNING: Gateway ${GATEWAY_IP} not reachable"
    ERRORS=$(( ERRORS + 1 ))
fi

echo ""
log "--- External internet (8.8.8.8) ---"
if ping -c 2 -W 5 8.8.8.8 &>/dev/null; then
    log "OK  External internet reachable"
else
    log "WARNING: External internet not reachable (CGNAT or no internet)"
    ERRORS=$(( ERRORS + 1 ))
fi

echo ""
log "--- DNS resolution ---"
if host google.com &>/dev/null 2>&1; then
    log "OK  External DNS working"
else
    log "WARNING: External DNS not resolving"
    ERRORS=$(( ERRORS + 1 ))
fi

echo ""
log "--- NetworkManager connections ---"
if command -v nmcli &>/dev/null; then
    nmcli -t -f NAME,DEVICE,STATE connection show 2>/dev/null | while IFS=: read -r name dev state; do
        printf "  %-30s  dev=%-12s  %s\n" "${name}" "${dev}" "${state}"
    done
else
    log "INFO: nmcli not available"
fi

echo ""
log "--- Listening ports ---"
for port in "${LISTEN_PORTS[@]}"; do
    if ss -tlnp 2>/dev/null | grep -q ":${port} "; then
        log "OK  :${port} is LISTEN"
    else
        log "INFO: :${port} not listening (service may not be deployed yet)"
    fi
done

echo ""
log "=== Network health check finished — issues: ${ERRORS} ==="
if (( ERRORS > 0 )); then
    exit 1
fi