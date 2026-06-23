# Reliability Audit 2026-06-23

## 1. Scope

Live audit through the VPS reverse SSH tunnel after the 250 GB SSD was
reconnected. Goal: identify reliability risks that prevent automatic recovery
after USB reconnects, container crashes, or power loss.

No destructive storage operations were performed during this audit.

## 2. Live Findings

| ID | Severity | Area | Finding | Status |
|---|---|---|---|---|
| R-01 | Critical | Storage | SSD is visible again as Realtek RTL9210B-CG `/dev/sda1`, mounted at `/mnt/storage`, but kernel logged repeated `EXT4-fs error ... comm apache2` while Nextcloud was running. | Open |
| R-02 | Critical | Nextcloud | HTTP 503 was caused by the storage remounting read-only during the USB incident. Step 2 review found `.ncdata`, config, data ownership and DB state consistent. App container is still stopped pending controlled start. | Review clean / start pending |
| R-03 | High | Boot ordering | Docker can start before `/mnt/storage` is safely mounted, which can create/write bind-mount data under a plain microSD directory after power loss. | Mitigation added in repo |
| R-04 | High | Runtime drift | Jetson `~/nasa` was behind `origin/main` and had live changes. It is now clean at `6844447`; the pre-sync live diff is preserved as `stash@{0}`. | Fixed live + repo |
| R-05 | Medium | Reporting | Daily report and nasa-api expected old compose-generated container names, causing false `missing` warnings. | Fixed in repo |
| R-06 | Medium | Restart policy | `docker-compose.stage1.yml`, Samba and VPS nginx still used `restart: unless-stopped` in repo templates. | Fixed in repo |
| R-07 | Medium | Failed units | `jetson-nas-health.service` and `nasa-backup.service` were updated and rerun successfully; `systemctl --failed` reports zero failed units. | Fixed live + repo |
| R-08 | Medium | Sudo access | Sudo was available through an existing private runtime secret; no password value was committed or documented. | Resolved for this recovery |

## 3. Evidence Snapshot

```text
Tunnel: VPS 127.0.0.1:10022 -> Jetson SSH OK
SSD: /dev/sda1 ext4 label=nasa-storage mounted rw,noatime at /mnt/storage
Disk: 229G total, 525M used, 217G free
e2fsck: e2fsck -f -n returned 0, no repairs required
Preflight: sudo storage_preflight.sh returned errors=0 warnings=0
Nextcloud: container stopped intentionally, restart=no, HTTP 503 before stop
Nextcloud review: logs show read-only data-dir writes failed; current mount is rw
Nextcloud data: `.ncdata` present, data dir 33:33 mode 750, no ownership drift
Nextcloud DB: pg_isready OK; users=1, filecache=76, file_locks=0
Immich: HTTP 200
LLM Gateway: HTTP 200
nasa-api: HTTP 200
Backup: fresh nextcloud and immich DB dumps created at 2026-06-23 09:32 UTC
Failed units: 0
New kernel storage errors after stopping Nextcloud: none observed
Jetson checkout: clean at 6844447 after `git pull --ff-only origin main`
Pre-sync live diff: preserved as git stash `stash@{0}`
```

## 4. Repo Mitigations Added

- Correct expected container names in:
  - `docker/compose/docker-compose.nasa-api.yml`
  - `services/nasa-api/app/config.py`
  - `scripts/monitoring/nasa-daily-report.sh`
- Daily report now checks:
  - real `/mnt/storage` mount source/fstype/options;
  - read-only or microSD-backed storage;
  - Nextcloud `.ncdata` presence when readable;
  - recent kernel storage errors;
  - separate VPS checks for Nextcloud, Immich and LLM Gateway.
- `nasa-backup.service` now has `RequiresMountsFor=/mnt/storage`,
  `ConditionPathIsMountPoint=/mnt/storage`, and `ExecStartPre=mountpoint`.
- `jetson-nas-health.service` now uses `/home/admin/nasa` and also requires
  `/mnt/storage` to be a mountpoint.
- Optional strict Docker boot guard:
  - `systemd/docker.service.d/10-nasa-storage.conf`
  - `scripts/storage/install_docker_storage_guard.sh`
- `restart: always` normalized for Samba, Stage 1 compose, and VPS nginx.

## 5. Required Live Recovery Order

Step 1 completed on 2026-06-23: Jetson `~/nasa` was synchronized with
`origin/main` without discarding local changes. The dirty pre-sync state was
saved with `git stash -u` as `stash@{0}: pre-sync live Jetson checkout
2026-06-23 step1`.

Step 2 completed on 2026-06-23: Nextcloud data/app review stayed read-only and
found no data-marker, ownership, config or DB blocker. The observed 503 cause
was the earlier read-only filesystem state:

```text
fopen(/var/www/html/data/data_dir_writability_test_...tmp): Read-only file system
fopen(/var/www/html/data/nextcloud.log): Read-only file system
```

Current safe-state evidence:

```text
/mnt/storage: /dev/sda1 ext4 rw,noatime,data=ordered
/mnt/storage/nextcloud/data: mode 750, owner 33:33
`.ncdata`: present, owner 33:33
writability_test leftovers: 0
non-33 owner/group entries under data dir: 0
DB: accepting connections, file_locks=0
homecloud_nextcloud: exited, restart=no
```

Path A was completed on 2026-06-23: storage-backed containers were stopped,
`/mnt/storage` was unmounted, `e2fsck -f -n` returned 0, the filesystem was
remounted, preflight passed, and non-Nextcloud services were restarted.

Do not start Nextcloud as a blind restart. Use the controlled start below so a
new read-only remount or HTTP 503 is caught immediately.

### Controlled Nextcloud start

Before start:

```bash
cd ~/nasa
sudo bash scripts/storage/storage_preflight.sh
sudo journalctl -k --since "10 minutes ago" --no-pager \
  | grep -i -E "ext4|I/O error|error -71|read-only" || true
```

Start and observe:

```bash
docker update --restart=always homecloud_nextcloud
docker start homecloud_nextcloud
docker logs -f --tail=80 homecloud_nextcloud
curl -i http://127.0.0.1:8080/status.php
```

### Optional Path B: Reformat SSD for maximum reliability

Requires explicit confirmation immediately before the destructive command.
Current target, if confirmed:

```text
/dev/disk/by-id/usb-Realtek_RTL9210B-CG_012345679039-0:0-part1
UUID target mount: /mnt/storage
filesystem: ext4
label: nasa-storage
```

Formatting is not currently required by read-only fsck. If chosen anyway, first
export or intentionally discard current data, recreate the storage tree, apply
the Docker storage guard, then start services in this order: DB/Redis, Immich,
LLM Gateway/nasa-api, Samba, Nextcloud last.

## 6. Remaining Design Risks

- A single USB SSD is not a backup. Off-device restic backup is still required.
- Jetson Nano USB power/cable stability remains the most likely hardware weak
  point; repeated `error -71` means cable/enclosure/power should be treated as
  suspect even when the SSD is currently visible.
- Docker restart policy alone is not enough. Boot ordering must prevent Docker
  from using false bind-mount directories before `/mnt/storage` is mounted.
- Nextcloud must stay stopped until the previous HTTP 503 and apache2/ext4
  errors are understood. Creating `.ncdata` manually as a shortcut is not a
  reliability fix and can hide data inconsistency.
