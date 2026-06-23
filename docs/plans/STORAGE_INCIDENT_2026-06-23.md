# Storage Incident 2026-06-23

## 1. Summary

On 2026-06-23 the Jetson Nano was reachable through the VPS reverse SSH tunnel,
but storage-backed services were degraded because the 250 GB USB storage device
was no longer present as a block device.

The failure is below Docker and Nextcloud: the kernel repeatedly fails to
enumerate the USB device on `usb 1-2.1` with `error -71`.

## 2. Observed State

| Area | Result |
|---|---|
| Jetson SSH via VPS | OK: `ssh root@193.8.215.130` then `ssh -p 10022 admin@127.0.0.1` |
| `/mnt/storage` on host | Not a mountpoint |
| Block devices | Only microSD and zram visible; 250 GB disk absent |
| USB topology | Realtek hub visible, storage LUN absent |
| Nextcloud | Degraded: HTTP 503, container unhealthy |
| Immich | Responds to `/api/server/ping` |
| LLM Gateway | Responds to `/health` |
| nasa-api | Responds to `/healthcheck` |
| Backup timer | Failed closed; no safe storage target |

## 3. Kernel Evidence

Important kernel messages:

```text
usb 1-2.1: device descriptor read/64, error -71
usb 1-2-port1: unable to enumerate USB device
blk_update_request: I/O error, dev sda
Aborting journal on device sda1-8
EXT4-fs (sda1): Remounting filesystem read-only
EXT4-fs error (device sdb1): ext4_find_entry
```

Initial successful detection on 2026-06-21:

```text
Realtek RTL9210B-CG
[sda] 488397168 512-byte logical blocks: (250 GB/233 GiB)
sda: sda1
EXT4-fs (sda1): mounted filesystem
```

## 4. Safety Rules

Do not:

- create `.ncdata` manually while `/mnt/storage` is not mounted;
- start Nextcloud or Immich while `storage_preflight.sh` fails;
- run `fsck` against a mounted filesystem;
- run `docker compose down -v`;
- write backups into a false `/mnt/storage` directory on microSD;
- touch Amnezia VPN containers or router firewall/VPN settings.

## 5. Recovery Order

1. Physically stabilize the USB chain: cable, port, powered hub, enclosure,
   power supply.
2. Confirm the disk is visible:

```bash
lsblk -o NAME,TYPE,SIZE,FSTYPE,LABEL,MOUNTPOINT,MODEL,RO
blkid
journalctl -k -n 120 --no-pager
```

3. Run preflight:

```bash
cd ~/nasa
sudo bash scripts/storage/storage_preflight.sh
```

4. Only after the disk is stable and preflight is clean, install/start the mount
   unit and restart storage-backed services.

## 6. Follow-Up Changes

- `scripts/backup/backup_databases.sh` now refuses to write when storage is not
  safely mounted.
- `scripts/storage/storage_preflight.sh` provides a single pre-start gate for
  storage-backed services.
- `scripts/storage/install_mount_service.sh` installs the mount unit without
  mounting immediately unless `--start` is passed.
- `docs/13_MONITORING_RUNBOOK.md` now contains the incident workflow.
