#!/usr/bin/env bash
# install_backup_timer.sh — deploy nasa-backup.{service,timer} to Jetson systemd
# Run ON JETSON NANO as admin (sudo will be prompted):
#   bash scripts/backup/install_backup_timer.sh
set -euo pipefail

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/../.."
SYSTEMD_SRC="${REPO_ROOT}/systemd"
SYSTEMD_DST="/etc/systemd/system"
NASA_DIR="$(realpath "${REPO_ROOT}")"
SERVICE_FILE="${SYSTEMD_DST}/nasa-backup.service"

# Patch NASA_PROJECT_DIR inside the service file at install time
log "Installing nasa-backup.service with NASA_PROJECT_DIR=${NASA_DIR}"
sudo sed "s|/home/admin/nasa|${NASA_DIR}|g" \
    "${SYSTEMD_SRC}/nasa-backup.service" \
    | sudo tee "${SERVICE_FILE}" > /dev/null

sudo cp "${SYSTEMD_SRC}/nasa-backup.timer" "${SYSTEMD_DST}/nasa-backup.timer"
sudo chmod 644 "${SERVICE_FILE}" "${SYSTEMD_DST}/nasa-backup.timer"

sudo systemctl daemon-reload
sudo systemctl enable nasa-backup.timer
sudo systemctl start nasa-backup.timer

log "Timer enabled. Current state:"
systemctl status nasa-backup.timer --no-pager
systemctl list-timers nasa-backup.timer --no-pager
log "Next run at 03:00 (±15 min). Test run now: sudo systemctl start nasa-backup.service"
