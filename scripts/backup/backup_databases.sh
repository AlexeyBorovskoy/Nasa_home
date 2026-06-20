#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# backup_databases.sh — dump PostgreSQL databases from running Docker containers
# ---------------------------------------------------------------------------
# Usage: ./backup_databases.sh
# Reads config from ../../config/.env relative to this script's location.
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../../config/.env"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# Load environment if available
if [[ -f "${ENV_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${ENV_FILE}"
    log "Loaded env from ${ENV_FILE}"
fi

# ---- Defaults (overridden by .env) ----------------------------------------
BACKUP_ROOT="${BACKUP_ROOT:-/mnt/storage/backups}"
STORAGE_ROOT="${STORAGE_ROOT:-/mnt/storage}"
BACKUP_KEEP_LAST="${BACKUP_KEEP_LAST:-7}"

NEXTCLOUD_DB_CONTAINER="homecloud_nextcloud_db"
IMMICH_DB_CONTAINER="homecloud_immich_db"

NEXTCLOUD_DB_USER="${NEXTCLOUD_DB_USER:-nextcloud}"
NEXTCLOUD_DB_NAME="${NEXTCLOUD_DB_NAME:-nextcloud}"
IMMICH_DB_USER="${IMMICH_DB_USER:-immich}"
IMMICH_DB_NAME="${IMMICH_DB_NAME:-immich}"

DUMP_DIR="${BACKUP_ROOT}/database-dumps"
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

container_running() {
    local name="$1"
    docker inspect --format '{{.State.Running}}' "${name}" 2>/dev/null | grep -q '^true$'
}

dump_postgres() {
    local container="$1"
    local db_user="$2"
    local db_name="$3"
    local out_file="$4"

    log "Dumping ${db_name} from ${container} → ${out_file}.gz"
    docker exec "${container}" \
        pg_dump -U "${db_user}" "${db_name}" \
        | gzip > "${out_file}.gz"
    log "Done: $(du -sh "${out_file}.gz" | cut -f1)"
}

rotate_old_dumps() {
    local prefix="$1"
    local keep="${BACKUP_KEEP_LAST}"
    log "Rotating old dumps for pattern '${prefix}' — keeping last ${keep}"
    # List files matching prefix, sorted oldest first, delete beyond keep count
    local files
    mapfile -t files < <(ls -t "${DUMP_DIR}"/${prefix}_*.sql.gz 2>/dev/null)
    local total="${#files[@]}"
    if (( total > keep )); then
        local to_delete=$(( total - keep ))
        log "Deleting ${to_delete} old dump(s)"
        for f in "${files[@]:${keep}}"; do
            rm -f "${f}"
            log "Removed: ${f}"
        done
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

log "=== Database backup started ==="
mkdir -p "${DUMP_DIR}"

ERRORS=0

# --- Nextcloud PostgreSQL ---------------------------------------------------
if container_running "${NEXTCLOUD_DB_CONTAINER}"; then
    NC_FILE="${DUMP_DIR}/nextcloud_${TIMESTAMP}.sql"
    if dump_postgres "${NEXTCLOUD_DB_CONTAINER}" \
                     "${NEXTCLOUD_DB_USER}" \
                     "${NEXTCLOUD_DB_NAME}" \
                     "${NC_FILE}"; then
        rotate_old_dumps "nextcloud"
    else
        log "ERROR: Nextcloud dump failed"
        ERRORS=$(( ERRORS + 1 ))
    fi
else
    log "WARNING: Container ${NEXTCLOUD_DB_CONTAINER} is not running — skipping"
    ERRORS=$(( ERRORS + 1 ))
fi

# --- Immich PostgreSQL ------------------------------------------------------
if container_running "${IMMICH_DB_CONTAINER}"; then
    IM_FILE="${DUMP_DIR}/immich_${TIMESTAMP}.sql"
    if dump_postgres "${IMMICH_DB_CONTAINER}" \
                     "${IMMICH_DB_USER}" \
                     "${IMMICH_DB_NAME}" \
                     "${IM_FILE}"; then
        rotate_old_dumps "immich"
    else
        log "ERROR: Immich dump failed"
        ERRORS=$(( ERRORS + 1 ))
    fi
else
    log "WARNING: Container ${IMMICH_DB_CONTAINER} is not running — skipping"
    ERRORS=$(( ERRORS + 1 ))
fi

# ---------------------------------------------------------------------------
log "=== Database backup finished — errors: ${ERRORS} ==="
if (( ERRORS > 0 )); then
    exit 1
fi
