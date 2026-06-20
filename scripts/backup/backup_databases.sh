#!/usr/bin/env bash
set -euo pipefail
TS="$(date +%Y%m%d_%H%M%S)"
OUT="${BACKUP_ROOT:-/mnt/storage/backups}/database-dumps/$TS"
mkdir -p "$OUT"

echo "Database backup placeholder. Adapt container names after deployment."
echo "Target: $OUT"

# Examples:
# docker exec homecloud_nextcloud_db pg_dump -U "$NEXTCLOUD_DB_USER" "$NEXTCLOUD_DB_NAME" > "$OUT/nextcloud.sql"
# docker exec homecloud_immich_db pg_dump -U "$IMMICH_DB_USER" "$IMMICH_DB_NAME" > "$OUT/immich.sql"
