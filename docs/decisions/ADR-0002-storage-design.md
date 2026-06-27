# ADR-0002: Дизайн хранилища — USB HDD + ext4 + /mnt/storage
# ADR-0002: Storage Design — USB HDD + ext4 + /mnt/storage

## Статус / Status

🇷🇺 Принято. / 🇬🇧 Accepted.

## Контекст / Context

🇷🇺 Jetson Nano не имеет встроенного HDD/SSD. Проект требует нескольких сотен ГБ для фото/видео (Immich), файлов (Nextcloud) и БД.
🇬🇧 Jetson Nano has no built-in HDD/SSD. The project needs several hundred GB for photos/video (Immich), files (Nextcloud), and databases.

## Рассмотренные варианты / Options considered

| Вариант / Option | Плюсы / Pros | Минусы / Cons |
|---|---|---|
| microSD только / only | Уже есть / already present | Ресурс 10K циклов, медленно для БД / 10K write cycles, slow for DB |
| **USB HDD (внешнее питание / external power)** | Дёшево, большой объём / cheap, large | Требует питания / needs power supply |
| USB SSD | Быстро, надёжно / fast, reliable | Дороже / more expensive |
| NFS | Масштабируется / scalable | Зависимость от второго устройства / depends on second device |
| eMMC | Встроен / built-in | Только 16 GB |

## Решение / Decision

🇷🇺 USB HDD с отдельным блоком питания, **ext4**, смонтирован как `/mnt/storage`.
🇬🇧 USB HDD with a dedicated power supply, **ext4**, mounted at `/mnt/storage`.

🇷🇺 Структура / 🇬🇧 Layout:

```
/mnt/storage/
├── nextcloud/data/          # файлы пользователей / user files
├── immich/library/          # фото и видео / photos and videos
├── db/
│   ├── nextcloud-postgres/
│   └── immich-postgres/
├── backups/
│   ├── database-dumps/      # pg_dump, gzip, 7 retained
│   └── restic-repo/
└── samba/
```

🇷🇺 Монтирование через `/etc/fstab` по UUID с `defaults,nofail`.
🇬🇧 Mounted via `/etc/fstab` by UUID with `defaults,nofail`.

## Временная конфигурация Stage 1 / Stage 1 temporary configuration

🇷🇺 USB-флешка вместо HDD — для проверки Docker Compose и путей без риска для реальных данных.
🇬🇧 USB flash drive instead of HDD — to verify Docker Compose and paths without risk to real data.

## Последствия / Consequences

- 🇷🇺 `fstab` должен иметь `nofail` — Jetson загружается без диска / 🇬🇧 `fstab` must have `nofail` — Jetson boots without disk
- 🇷🇺 `scripts/diagnostics/storage_health.sh` проверяет монтирование перед операциями / 🇬🇧 `scripts/diagnostics/storage_health.sh` verifies mount before operations
- 🇷🇺 Все пути задаются через `config/.env` (STORAGE_ROOT, NEXTCLOUD_DATA и т.д.) / 🇬🇧 All paths configured via `config/.env` (STORAGE_ROOT, NEXTCLOUD_DATA, etc.)
