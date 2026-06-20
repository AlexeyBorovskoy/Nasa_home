#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# docker_update_plan.sh — pull new images and rolling update of homecloud stack
# ---------------------------------------------------------------------------
# Usage: ./docker_update_plan.sh
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../../config/.env"
COMPOSE_FILE="${SCRIPT_DIR}/../../docker/compose/docker-compose.stage1.yml"
HEALTH_SCRIPT="${SCRIPT_DIR}/../diagnostics/docker_health.sh"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

if [[ -f "${ENV_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${ENV_FILE}"
    log "Loaded env from ${ENV_FILE}"
fi

# Verify compose file exists
if [[ ! -f "${COMPOSE_FILE}" ]]; then
    log "ERROR: Compose file not found: ${COMPOSE_FILE}"
    exit 1
fi

COMPOSE="docker compose -f ${COMPOSE_FILE}"

# ---------------------------------------------------------------------------
# 1. Pre-update database dump
# ---------------------------------------------------------------------------
log "=== Docker stack update started ==="
DB_SCRIPT="${SCRIPT_DIR}/../backup/backup_databases.sh"
if [[ -x "${DB_SCRIPT}" ]]; then
    log "Running pre-update database dump..."
    "${DB_SCRIPT}"
else
    log "WARNING: ${DB_SCRIPT} not found or not executable — skipping pre-update DB dump"
fi

# ---------------------------------------------------------------------------
# 2. Pull latest images
# ---------------------------------------------------------------------------
log "Pulling latest images..."
${COMPOSE} pull

# ---------------------------------------------------------------------------
# 3. Graceful stop
# ---------------------------------------------------------------------------
log "Stopping running stack gracefully..."
${COMPOSE} down --timeout 30

# ---------------------------------------------------------------------------
# 4. Bring up with new images
# ---------------------------------------------------------------------------
log "Starting stack with new images..."
${COMPOSE} up -d

# ---------------------------------------------------------------------------
# 5. Wait for containers to stabilise
# ---------------------------------------------------------------------------
log "Waiting 15 seconds for containers to stabilise..."
sleep 15

# ---------------------------------------------------------------------------
# 6. Health check
# ---------------------------------------------------------------------------
log "Running health check..."
if [[ -x "${HEALTH_SCRIPT}" ]]; then
    if "${HEALTH_SCRIPT}"; then
        log "Health check PASSED — update successful"
    else
        log "CRITICAL: Health check FAILED after update"
        log "Showing logs for all containers:"
        ${COMPOSE} logs --tail=30
        exit 1
    fi
else
    log "WARNING: Health script not found at ${HEALTH_SCRIPT} — skipping"
    log "Manual check: run 'docker compose -f ${COMPOSE_FILE} ps'"
fi

log "=== Docker stack update completed successfully ==="
