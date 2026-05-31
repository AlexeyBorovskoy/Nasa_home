#!/usr/bin/env bash
set -euo pipefail
: "${RESTIC_REPOSITORY:?Set RESTIC_REPOSITORY}"
: "${RESTIC_PASSWORD:?Set RESTIC_PASSWORD or RESTIC_PASSWORD_FILE}"

restic snapshots || restic init
restic backup /mnt/storage/nextcloud /mnt/storage/immich /mnt/storage/backups/database-dumps
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --prune
