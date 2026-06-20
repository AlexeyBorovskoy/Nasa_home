# 04. Дизайн хранилища

## 1. Цель

USB HDD является основным хранилищем данных. microSD используется для ОС и минимального runtime.

## 2. Рекомендуемая файловая система

Рекомендуется `ext4`, если диск постоянно используется с Linux-сервером.

NTFS допустим только как временный режим, если диск нужно регулярно подключать к Windows. Для БД Immich/Nextcloud NTFS не рекомендуется.

## 3. Существующий HDD с данными

Частый сценарий: пользователь подключает к Jetson уже используемый USB HDD, часто
с файловой системой NTFS и личными данными. Такой диск нельзя сразу превращать в
рабочий `/mnt/storage` и нельзя запускать `scripts/storage/setup_disk.sh`, пока
не подтверждено, что данные сохранены и есть отдельный план миграции.

Безопасный порядок:

1. Остановить сервисы, которые могут писать в `/mnt/storage`, если они уже
   запущены. Использовать только `stop`; не использовать `down -v`.
2. Проверить, что `/mnt/storage` сейчас действительно смонтирован на внешний диск,
   а не является обычным каталогом на microSD.
3. Найти диск и раздел через `lsblk`.
4. Смонтировать существующий раздел только для чтения в отдельную точку, например
   `/mnt/hdd-check`.
5. Проверить размер, файловую систему, метку и наличие данных без вывода личных
   имён файлов в публичные отчёты.
6. Только после этого выбрать отдельный сценарий: оставить NTFS как временный
   read-only источник, скопировать данные на новый ext4-диск или сделать backup и
   затем подготовить диск под Linux.

Команды для безопасного read-only intake:

```bash
# 1. Если Nextcloud/Immich уже запущены, остановить их перед проверкой storage.
# Пример для Nextcloud-only deployment:
docker compose -f docker/compose/docker-compose.nextcloud.yml --env-file config/.env stop

# 2. Убедиться, что /mnt/storage не является "ложным" каталогом на microSD.
mountpoint /mnt/storage || echo "/mnt/storage is not mounted"
du -sh /mnt/storage 2>/dev/null || true

# 3. Найти HDD и раздел.
lsblk -o NAME,TYPE,SIZE,FSTYPE,LABEL,MOUNTPOINT,MODEL,TRAN,RO

# 4. Проверить NTFS-драйвер и смонтировать существующий NTFS-раздел только для чтения.
command -v ntfs-3g || sudo apt install -y ntfs-3g
sudo mkdir -p /mnt/hdd-check
sudo mount -t ntfs-3g -o ro /dev/sdXN /mnt/hdd-check

# 5. Подтвердить read-only режим и наличие данных без раскрытия содержимого.
findmnt /mnt/hdd-check
df -hT /mnt/hdd-check
find /mnt/hdd-check -mindepth 1 -maxdepth 1 | wc -l
```

Если NTFS-раздел помечен как dirty/hibernated, не использовать `force` и не
исправлять его на Jetson. Безопаснее отключить диск, проверить его на Windows
(`chkdsk`) и вернуться к read-only проверке.

Важно: монтирование диска в `/mnt/storage` скрывает уже существующие файлы в
одноимённом каталоге на microSD. Перед любым постоянным mount/fstab изменением
нужно проверить `du -sh /mnt/storage` и решить, нужно ли сохранять эти временные
данные.

## 4. Целевая структура

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

## 5. Создание каталогов

```bash
sudo mkdir -p /mnt/storage/{nextcloud/data,nextcloud/config-backup}
sudo mkdir -p /mnt/storage/{immich/library,immich/upload,immich/profile}
sudo mkdir -p /mnt/storage/db/{nextcloud-postgres,immich-postgres,redis}
sudo mkdir -p /mnt/storage/samba/{public,exchange,family}
sudo mkdir -p /mnt/storage/backups/{database-dumps,configs,restic-repo}
sudo mkdir -p /mnt/storage/diagnostics/{hardware,docker,logs}
sudo chown -R $USER:$USER /mnt/storage
```

## 6. Автомонтирование

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

## 7. Критический контроль

После перезагрузки:

```bash
mount | grep /mnt/storage
df -h /mnt/storage
sudo dmesg | grep -i -E "error|reset|i/o" | tail -n 100
```
