# 04. Дизайн хранилища

## 1. Цель

USB HDD является основным хранилищем данных. microSD используется для ОС и минимального runtime.

## 2. Рекомендуемая файловая система

Рекомендуется `ext4`, если диск постоянно используется с Linux-сервером.

NTFS допустим только как временный режим, если диск нужно регулярно подключать к Windows. Для БД Immich/Nextcloud NTFS не рекомендуется.

## 3. Целевая структура

```text
/mnt/storage
├── nextcloud/
│   ├── data/
│   └── config-backup/
├── immich/
│   ├── library/
│   ├── upload/
│   └── profile/
├── db/
│   ├── nextcloud-postgres/
│   ├── immich-postgres/
│   └── redis/
├── samba/
│   ├── public/
│   ├── exchange/
│   └── family/
├── backups/
│   ├── database-dumps/
│   ├── configs/
│   └── restic-repo/
└── diagnostics/
    ├── hardware/
    ├── docker/
    └── logs/
```

## 4. Создание каталогов

```bash
sudo mkdir -p /mnt/storage/{nextcloud/data,nextcloud/config-backup}
sudo mkdir -p /mnt/storage/{immich/library,immich/upload,immich/profile}
sudo mkdir -p /mnt/storage/db/{nextcloud-postgres,immich-postgres,redis}
sudo mkdir -p /mnt/storage/samba/{public,exchange,family}
sudo mkdir -p /mnt/storage/backups/{database-dumps,configs,restic-repo}
sudo mkdir -p /mnt/storage/diagnostics/{hardware,docker,logs}
sudo chown -R $USER:$USER /mnt/storage
```

## 5. Автомонтирование

Получить UUID:

```bash
sudo blkid
```

Пример `/etc/fstab`:

```text
UUID=<HDD_UUID> /mnt/storage ext4 defaults,noatime 0 2
```

Проверка:

```bash
sudo mount -a
df -h /mnt/storage
```

## 6. Критический контроль

После перезагрузки:

```bash
mount | grep /mnt/storage
df -h /mnt/storage
sudo dmesg | grep -i -E "error|reset|i/o" | tail -n 100
```
