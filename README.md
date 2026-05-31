# NASA Home Cloud

> RU: инженерный шаблон приватного семейного облака для Jetson Nano / ARM / SBC.
>
> EN: Codex-ready blueprint for a private family cloud on low-power home hardware.

## Русская версия

### Что это

**NASA Home Cloud** — проект домашней семейной облачной платформы на базе **NVIDIA Jetson Nano + USB HDD**. Его цель — заменить часть функций Google/Xiaomi Cloud на собственную инфраструктуру: файлы, документы, контакты, календарь, фотоархив, локальный NAS, резервное копирование и безопасный LLM-помощник администратора.

Проект пока не является production-инсталлятором в один клик. Это инженерный шаблон: документация, Docker Compose, диагностические скрипты, API-заготовки и промпты для Codex/агентов, чтобы разворачивать платформу малыми проверяемыми шагами.

### Что разворачивается

```text
Android-телефоны и ноутбуки
        |
        | только LAN / VPN
        v
Jetson Nano + USB HDD
        |
        +-- Nextcloud: файлы, документы, контакты, календарь, WebDAV
        +-- Immich: фото- и видеоархив
        +-- Samba/SFTP: локальный NAS-доступ
        +-- Backup/Restore: дампы БД и restic-снапшоты
        +-- LLM Gateway: DeepSeek API через privacy-фильтр
        +-- Backup API: заготовка Stage 2 для будущего Android restore
```

### Принципы проекта

- **Приватность прежде всего:** фото, видео, контакты, календарь, документы и backup-манифесты не отправляются во внешний LLM.
- **Только LAN/VPN:** Nextcloud, Immich, LLM Gateway и SSH не публикуются напрямую в интернет.
- **Малые шаги:** каждый технический блок разворачивается отдельно и проверяется перед следующим.
- **Без секретов в git:** реальные `.env`, токены, API-ключи, приватные ключи, дампы, логи и персональные данные не попадают в репозиторий.
- **Без локальной LLM на Jetson Nano в Stage 1:** Jetson используется как домашний сервер, а не как inference-нода.

### Стек

| Область | Компонент |
|---|---|
| Файлы и документы | Nextcloud |
| Контакты и календарь | Nextcloud Contacts/Calendar + DAVx5 |
| Фото и видео | Immich |
| Локальный NAS | Samba + SFTP |
| Базы данных | PostgreSQL + Redis |
| Резервное копирование | DB dumps + restic |
| LLM-помощник | DeepSeek API через `services/llm-gateway` |
| Будущее восстановление Android | Android Stage 2 + `services/backup-api` |

### Целевое железо

| Компонент | Рекомендация |
|---|---|
| Вычислительный узел | NVIDIA Jetson Nano Developer Kit |
| Системный диск | microSD 64 GB или больше |
| Диск данных | USB HDD с отдельным питанием |
| Сеть | Ethernet для Jetson, Wi-Fi для клиентов |
| Роутер | гигабитный роутер со static DHCP lease |
| Внешний доступ | только VPN / mesh VPN |

Jetson Nano ограничен по RAM и CPU. Тяжёлый ML-анализ фото, массовое видеотранскодирование и локальный inference LLM специально вынесены за пределы Stage 1.

### Структура репозитория

```text
config/
  .env.example              публичный шаблон переменных окружения
  llm-policy.yaml           черновик privacy-policy для LLM Stage 1

docker/compose/
  docker-compose.stage1.yml полный черновик Stage 1
  docker-compose.nextcloud.yml
  docker-compose.immich.yml
  docker-compose.llm-gateway.yml

docs/
  00_OVERVIEW.md
  01_HARDWARE_AUDIT.md
  01A_JETSON_SD_BOOTSTRAP.md
  03_ARCHITECTURE.md
  04_STORAGE_DESIGN.md
  05_NETWORKING_VPN.md
  06_NEXTCLOUD_DESIGN.md
  07_IMMICH_DESIGN.md
  08_LLM_GATEWAY_DEEPSEEK.md
  12_BACKUP_RESTORE.md
  14_TEST_PLAN.md
  16_GITHUB_PUBLICATION.md

services/
  llm-gateway/              FastAPI-шлюз с redaction и mock-режимом
  backup-api/               Stage 2 placeholder для Android backup/restore

scripts/
  diagnostics/              проверки железа, Docker и storage
  backup/                   примеры backup и заготовка DB dump
  security/                 проверки перед публикацией

prompts/
  CODEX_*                   промпты для поэтапной работы агентов
```

### Этапы

| Этап | Содержание | Статус |
|---|---|---|
| Stage 0 | Подготовка microSD и первый boot Jetson | описано |
| Stage 1A | Hardware audit, storage, Samba/SFTP | спроектировано |
| Stage 1B | Nextcloud | compose-черновик |
| Stage 1C | Immich в ограниченном режиме | compose-черновик |
| Stage 1D | DeepSeek LLM Gateway | FastAPI-скелет есть |
| Stage 1E | Backup/restore | документация и черновики скриптов |
| Stage 2 | Android backup/restore client | только архитектура |
| Stage 3 | аналитика, RAG, fallback-провайдеры | будущее |

### Быстрый старт для Codex/агентов

1. Прочитать `AGENTS.md`.
2. Прочитать `PROJECT_CONTEXT.md`.
3. Если готовой стартовой microSD нет, выполнить `docs/01A_JETSON_SD_BOOTSTRAP.md`.
4. После первого boot и SSH выполнить hardware audit на целевом хосте:

```bash
./scripts/diagnostics/hardware_audit.sh
```

5. Подготовить хранилище по `docs/04_STORAGE_DESIGN.md`, когда HDD будет доступен.
6. Создать локальный env-файл:

```bash
cp config/.env.example config/.env
chmod 600 config/.env
```

7. Локально заменить все placeholder-значения в `config/.env`. Не коммитить этот файл.
8. Разворачивать блоки по очереди: storage, NAS-доступ, Nextcloud, Immich, LLM Gateway, backups.

### Docker Compose

Compose-файлы используют современную спецификацию Compose, включая верхнеуровневый ключ `name:`. Нужен Docker Compose v2:

```bash
docker compose version
docker compose -f docker/compose/docker-compose.stage1.yml --env-file config/.env config
```

Старый `docker-compose` v1 может отклонить эти файлы.

### LLM Gateway

`services/llm-gateway` — небольшой FastAPI-сервис, который:

- принимает безопасные административные промпты;
- редактирует очевидные e-mail, телефоны, токены, пароли и приватные ключи;
- работает в mock-режиме, если `DEEPSEEK_API_KEY` не настроен;
- блокирует raw-mode в Stage 1.

Разрешено в Stage 1:

- объяснять обезличенные Docker-ошибки;
- суммировать состояние сервисов;
- генерировать runbook по диагностике без персональных данных;
- работать с проектной документацией.

Запрещено в Stage 1:

- анализировать личные фото и видео;
- отправлять контакты, календарь, документы, дампы БД, backup-манифесты, токены и приватные ключи;
- открывать LLM Gateway напрямую в интернет.

### Проверка перед публикацией

```bash
./scripts/security/check_no_secrets.sh
find . -name '.env' -o -name '*.key' -o -name '*.pem' -o -name '*.p12' -o -name '*.pfx'
```

Вывод нужно просмотреть вручную перед push. Репозиторий должен содержать только шаблоны, документацию и исходный код.

### Текущие ограничения

- Проект ещё не проверен на реальном Jetson.
- `backup_databases.sh` пока placeholder.
- Отключение Immich machine learning нужно явно довести в compose перед тестом на Jetson.
- `config/llm-policy.yaml` описывает целевую политику, но не все лимиты уже enforced в коде.
- `services/backup-api` — Stage 2 placeholder, не production backup-сервис.

### Roadmap

- `v0.1`: публичная документация и безопасный bootstrap репозитория.
- `v0.2`: hardware audit и storage scripts.
- `v0.3`: проверенный Nextcloud deployment.
- `v0.4`: проверенный Immich deployment с Jetson-safe настройками.
- `v0.5`: backup/restore workflow.
- `v0.6`: enforcement политики LLM Gateway.
- `v0.7`: Android Stage 2 API draft.
- `v1.0`: проверенная установка на Jetson Nano и одном дополнительном low-power устройстве.

## English Version

### What This Is

**NASA Home Cloud** is a Codex-ready blueprint for a private family cloud on **NVIDIA Jetson Nano + USB HDD**. It is intended to replace part of Google/Xiaomi Cloud with self-hosted files, documents, contacts, calendar, photo archive, local NAS access, backups, and a privacy-controlled LLM admin assistant.

This repository is not a one-command production installer yet. It is an engineering template with documentation, Docker Compose files, diagnostics, API skeletons, and agent prompts for safe step-by-step deployment.

### What This Project Builds

```text
Android phones and laptops
        |
        | LAN / VPN only
        v
Jetson Nano + USB HDD
        |
        +-- Nextcloud: files, documents, contacts, calendar, WebDAV
        +-- Immich: photo and video archive
        +-- Samba/SFTP: local NAS access
        +-- Backup/Restore: database dumps and restic snapshots
        +-- LLM Gateway: DeepSeek API through a privacy filter
        +-- Backup API: Stage 2 placeholder for future Android restore flows
```

### Core Principles

- **Privacy first:** personal photos, videos, contacts, calendars, documents, and backup manifests must not be sent to an external LLM.
- **LAN/VPN only:** Nextcloud, Immich, LLM Gateway, and SSH are not meant to be opened directly to the public internet.
- **Small steps:** every deployment block should be checked before moving to the next one.
- **No real secrets in git:** `.env`, tokens, API keys, private keys, dumps, logs, and personal data are excluded from the repository.
- **No local LLM on Jetson Nano in Stage 1:** Jetson Nano is used as a home server, not as an LLM inference node.

### Planned Stack

| Area | Component |
|---|---|
| Files and documents | Nextcloud |
| Contacts and calendar | Nextcloud Contacts/Calendar + DAVx5 |
| Photos and videos | Immich |
| Local NAS | Samba + SFTP |
| Databases | PostgreSQL + Redis |
| Backups | DB dumps + restic |
| LLM assistant | DeepSeek API through `services/llm-gateway` |
| Future mobile recovery | Android Stage 2 + `services/backup-api` |

### Target Hardware

| Component | Recommended value |
|---|---|
| Compute node | NVIDIA Jetson Nano Developer Kit |
| System drive | microSD 64 GB or larger |
| Data drive | USB HDD with external power |
| Network | Ethernet for Jetson, Wi-Fi for clients |
| Router | Gigabit router with static DHCP lease support |
| External access | VPN / mesh VPN only |

Jetson Nano has limited RAM and CPU headroom. Heavy ML photo analysis, large video transcoding jobs, and local LLM inference are intentionally out of scope for Stage 1.

### Quick Start For Agents

1. Read `AGENTS.md`.
2. Read `PROJECT_CONTEXT.md`.
3. If there is no prepared boot microSD card, follow `docs/01A_JETSON_SD_BOOTSTRAP.md`.
4. After first boot and SSH access, run the hardware audit on the target host:

```bash
./scripts/diagnostics/hardware_audit.sh
```

5. Prepare storage according to `docs/04_STORAGE_DESIGN.md` when the HDD is available.
6. Create a local environment file:

```bash
cp config/.env.example config/.env
chmod 600 config/.env
```

7. Replace all placeholder values in `config/.env` locally. Do not commit it.
8. Deploy one block at a time: storage, NAS access, Nextcloud, Immich, LLM Gateway, backups.

### Compose Compatibility Note

The compose files use the modern Compose specification, including the top-level `name:` key. Use Docker Compose v2:

```bash
docker compose version
docker compose -f docker/compose/docker-compose.stage1.yml --env-file config/.env config
```

Older `docker-compose` v1 may reject the files.

### Security Checklist Before Publishing

```bash
./scripts/security/check_no_secrets.sh
find . -name '.env' -o -name '*.key' -o -name '*.pem' -o -name '*.p12' -o -name '*.pfx'
```

Review the output manually before pushing. The repository is intended to contain only templates, documentation, and source code.

## License

MIT. See `LICENSE`.
