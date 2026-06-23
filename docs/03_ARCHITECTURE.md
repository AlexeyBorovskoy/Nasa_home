# 03. Архитектура

> Актуализировано: 2026-06-23. Полная карта — [archtectura_nasa.md](../archtectura_nasa.md).

## 1. Логическая схема

```mermaid
flowchart TB
    Client[Android / браузер]
    VPS["VPS 193.8.215.130\nnginx :8080/:2283/:8090"]
    Tunnel["SSH reverse tunnel\nnasa-tunnel.service (autossh)"]
    Jetson[Jetson Nano 4GB\n192.168.0.50]
    HDD[USB HDD]

    Nextcloud[Nextcloud :8080]
    Immich[Immich :2283]
    LLM[LLM Gateway :8090]
    Samba[Samba :445]
    Backup[Backup jobs]
    DeepSeek[DeepSeek API]

    NCDB[(PostgreSQL\nnextcloud)]
    ImmichDB[(PostgreSQL/pgvecto-rs\nimmich)]
    Redis[(Redis)]

    Client -->|internet| VPS
    VPS -->|18080/12283/18090| Tunnel
    Tunnel -->|autossh| Jetson
    Jetson --> HDD
    Jetson --> Nextcloud
    Jetson --> Immich
    Jetson --> Samba
    Jetson --> Backup
    Jetson --> LLM
    Nextcloud --> NCDB
    Nextcloud --> Redis
    Immich --> ImmichDB
    Immich --> Redis
    LLM --> DeepSeek
```

## 2. Слои

| Слой | Назначение |
|---|---|
| External relay | VPS nginx (host network) + SSH reverse tunnel через CGNAT |
| Storage | USB SSD/HDD, ext4, `/mnt/storage`; mounted after 2026-06-23 recovery, preflight required before storage-backed services |
| NAS | Samba/SMB2+ (LAN only) |
| Cloud | Nextcloud |
| Photo archive | Immich |
| Databases | PostgreSQL 16 (Nextcloud + Immich/pgvecto-rs), Redis 7 |
| AI | LLM Gateway → DeepSeek API (privacy-filtered) |
| Backup | pg_dump + restic |
| Future Android | Backup API + Android client (Stage 2) |

## 3. Порты

| Сервис | Порт Jetson | Внешний доступ | Статус |
|---|---|---|---|
| Nextcloud | 8080 | `http://193.8.215.130:8080/` | ⚠️ Intentionally stopped until data/app review |
| Immich | 2283 | `http://193.8.215.130:2283/` | ✅ Live |
| LLM Gateway | 8090 | `http://193.8.215.130:8090/` | ✅ Live |
| SSH управление | 22 | `ssh -p 10022 admin@127.0.0.1` с VPS | ✅ tunnel |
| Samba | 445/139 | LAN only (192.168.0.0/24) | ✅ Live; storage preflight required |

Прямого проброса портов на домашнем роутере нет.

## 4. VPS + reverse SSH tunnel

Обход CGNAT через исходящий SSH от Jetson:

```
Jetson → autossh -R 18080:localhost:8080
                 -R 12283:localhost:2283
                 -R 18090:localhost:8090
                 -R 10022:localhost:22
                 root@193.8.215.130
```

VPS nginx (`network_mode: host`) проксирует публичные порты на `127.0.0.1:18xxx`.  
Подробнее: [docs/decisions/ADR-0005-vps-autossh-reverse-tunnel.md](decisions/ADR-0005-vps-autossh-reverse-tunnel.md).

## 5. Принцип изоляции LLM

LLM Gateway получает только:
- обезличенные логи и статусы сервисов
- фрагменты проектной документации
- результаты диагностики без секретов

LLM Gateway **не получает**:
фото, видео, контакты, календарь, личные документы, ключи, backup-архивы.

## 6. Этапы

| Этап | Содержание | Статус |
|---|---|---|
| Stage 0 | microSD, first boot, SSH | ✅ |
| Stage 1A | Hardware audit, storage, Samba | ✅ Storage recovered; boot guard added |
| Stage 1B | Nextcloud | ⚠️ Stopped intentionally; DB/Redis healthy |
| Stage 1C | Immich (ML disabled) | ✅ Live |
| Stage 1D | LLM Gateway + DeepSeek | ✅ Live |
| Stage 1E | VPS + reverse SSH tunnel | ✅ Live |
| Stage 1F | Monitoring | ✅ |
| Stage 1G | Backup/restore | ✅ DB dumps working; fail-closed guard remains |
| Stage 2 | Android backup API | 📋 |
| Stage 3 | RAG, fallback LLM | 📋 |
