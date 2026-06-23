# 12. Backup / Restore

## 1. Правило

Хранение фото на одном USB HDD не является резервным копированием. Минимально нужен второй носитель или удалённая копия.

На 2026-06-23 backup работает в fail-closed режиме: если `/mnt/storage` не
является отдельным mountpoint или указывает на microSD, дампы БД не создаются.
Это защищает от записи backup-архивов в ложный каталог на системной microSD.

## 2. Объекты backup

| Объект | Метод |
|---|---|
| Nextcloud data | restic/borg |
| Nextcloud DB | pg_dump/mysqldump |
| Immich library | restic/borg |
| Immich DB | pg_dump |
| Docker compose/config | git + restic |
| `.env` | зашифрованный backup вне публичного Git |

## 3. Пример restic

Перед любым backup:

```bash
cd ~/nasa
sudo bash scripts/storage/storage_preflight.sh
```

```bash
export RESTIC_REPOSITORY=/mnt/storage/backups/restic-repo
export RESTIC_PASSWORD_FILE=/root/.config/homecloud/restic-password
restic init
restic backup /mnt/storage/nextcloud /mnt/storage/immich /mnt/storage/backups/database-dumps
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --prune
```

## 4. Проверка восстановления

Минимум раз в месяц:

```bash
restic snapshots
restic restore latest --target /tmp/homecloud-restore-test
ls -la /tmp/homecloud-restore-test
```

## 5. RPO/RTO

| Параметр | Цель Stage 1 |
|---|---:|
| RPO | 24 часа |
| RTO | 2–4 часа вручную |
| Проверка restore | ежемесячно |

## 6. USB Storage Incident 2026-06-23

Если preflight падает из-за отсутствующего `/mnt/storage`, `error -71` или
read-only remount, backup/restore работы останавливаются до стабилизации
накопителя. Порядок восстановления описан в
`docs/plans/STORAGE_INCIDENT_2026-06-23.md`.
