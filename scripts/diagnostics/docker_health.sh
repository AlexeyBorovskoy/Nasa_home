#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# docker_health.sh — check health of all homecloud Docker containers
# ---------------------------------------------------------------------------
# Returns exit code 1 if any critical container is down or unhealthy.
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../../config/.env"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

if [[ -f "${ENV_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${ENV_FILE}"
fi

# ---- Container list (name → port-to-probe, empty = skip curl) --------------
declare -A CONTAINERS=(
    [homecloud_nextcloud_db]=""
    [homecloud_nextcloud_redis]=""
    [homecloud_nextcloud]="8080"
    [homecloud_immich_db]=""
    [homecloud_immich_redis]=""
    [homecloud_immich_server]="2283"
    [homecloud_llm_gateway]="8090"
)

JETSON_LAN_IP="${JETSON_LAN_IP:-127.0.0.1}"
LOG_TAIL=10
ERRORS=0

# ---------------------------------------------------------------------------
check_container() {
    local name="$1"
    local port="$2"

    local status running health uptime

    status="$(docker inspect --format '{{.State.Status}}' "${name}" 2>/dev/null || echo "missing")"
    running="$(docker inspect --format '{{.State.Running}}' "${name}" 2>/dev/null || echo "false")"
    health="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}n/a{{end}}' "${name}" 2>/dev/null || echo "n/a")"
    uptime="$(docker inspect --format '{{.State.StartedAt}}' "${name}" 2>/dev/null || echo "unknown")"

    local status_icon="OK"
    [[ "${running}" != "true" ]] && status_icon="DOWN"
    [[ "${health}" == "unhealthy" ]] && status_icon="UNHEALTHY"

    printf "  %-30s  status=%-10s  health=%-10s  started=%s\n" \
        "${name}" "${status}" "${health}" "${uptime:0:19}"

    if [[ "${running}" != "true" ]]; then
        log "CRITICAL: ${name} is not running (status=${status})"
        ERRORS=$(( ERRORS + 1 ))
        return
    fi

    if [[ "${health}" == "unhealthy" ]]; then
        log "WARNING: ${name} is unhealthy — last ${LOG_TAIL} log lines:"
        docker logs --tail="${LOG_TAIL}" "${name}" 2>&1 | sed 's/^/    /'
        ERRORS=$(( ERRORS + 1 ))
    fi

    # Curl probe if port is set
    if [[ -n "${port}" ]]; then
        local url="http://${JETSON_LAN_IP}:${port}/"
        if curl -fsS --max-time 5 "${url}" -o /dev/null 2>/dev/null; then
            log "  Port ${port} OK (${url})"
        else
            log "  WARNING: Port ${port} not responding at ${url}"
            ERRORS=$(( ERRORS + 1 ))
        fi
    fi
}

# ---------------------------------------------------------------------------
log "=== Docker health check started ==="
echo ""
echo "  Container                         Status      Health      Started"
echo "  -----------------------------------------------------------------------"

for cname in "${!CONTAINERS[@]}"; do
    check_container "${cname}" "${CONTAINERS[${cname}]}"
done

echo ""
log "=== Docker health check finished — issues: ${ERRORS} ==="

if (( ERRORS > 0 )); then
    exit 1
fi
