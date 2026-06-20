# NASA Home Cloud
### _Old hardware should live_ · _Старое железо должно жить_

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Stage](https://img.shields.io/badge/Stage-1%20In%20Progress-orange)](docs/14_TEST_PLAN.md)
[![Platform](https://img.shields.io/badge/Platform-Jetson%20Nano-76b900)](https://developer.nvidia.com/embedded/jetson-nano-developer-kit)
[![Docker](https://img.shields.io/badge/Docker%20Compose-v2-2496ED)](docker/compose/)
[![AI-Assisted](https://img.shields.io/badge/Built%20with-Claude%20Code-blueviolet)](https://claude.ai/code)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

> 🇷🇺 Воспроизводимый шаблон приватного семейного облака на **NVIDIA Jetson Nano + старый HDD**.  
> Придумал человек — реализовал [Claude Code](https://claude.ai/code). Вся история в промптах и ADR.
>
> 🇬🇧 A reproducible private family cloud blueprint for **NVIDIA Jetson Nano + old HDD**.  
> Human vision, AI-assisted implementation. Every decision documented in ADRs and agent prompts.

---

## Содержание / Table of Contents

- [О проекте / About](#о-проекте--about)
- [Стек / Stack](#стек--stack)
- [Требования / Prerequisites](#требования--prerequisites)
- [Быстрый старт / Quick Start](#быстрый-старт--quick-start)
- [Конфигурация / Configuration](#конфигурация--configuration)
- [Архитектура / Architecture](#архитектура--architecture)
- [Этапы / Stages](#этапы--stages)
- [Мониторинг / Monitoring](#мониторинг--monitoring)
- [Документация / Documentation](#документация--documentation)
- [Безопасность / Security](#безопасность--security)
- [Вклад / Contributing](#вклад--contributing)
- [Лицензия / License](#лицензия--license)

---

## О проекте / About

> 🇷🇺 Русский

**NASA Home Cloud** — проект домашней семейной облачной платформы на базе **NVIDIA Jetson Nano + USB HDD**. Цель — заменить часть функций Google/Xiaomi Cloud на собственную инфраструктуру: файлы, документы, контакты, календарь, фотоархив, локальный NAS, резервное копирование и безопасный LLM-помощник администратора.

Это не production-инсталлятор в один клик. Это инженерный шаблон: документация, Docker Compose, диагностические скрипты, API-заготовки и промпты для Codex/агентов, позволяющие разворачивать платформу малыми проверяемыми шагами.

Принципы:

- **Приватность прежде всего** — фото, видео, контакты, календарь, документы и backup-манифесты не отправляются во внешний LLM.
- **Только LAN/VPN** — Nextcloud, Immich, LLM Gateway и SSH не публикуются напрямую в интернет.
- **Малые шаги** — каждый блок разворачивается отдельно и проверяется перед следующим.
- **Без секретов в git** — реальные `.env`, токены, ключи, дампы и персональные данные не попадают в репозиторий.
- **Без локальной LLM на Jetson Nano в Stage 1** — Jetson используется как домашний сервер, а не как inference-нода.

> 🇬🇧 English

**NASA Home Cloud** is a Codex-ready blueprint for a private family cloud on **NVIDIA Jetson Nano + USB HDD**. It is designed to replace part of Google/Xiaomi Cloud with self-hosted files, documents, contacts, calendar, photo archive, local NAS access, backups, and a privacy-controlled LLM admin assistant.

This repository is not a one-command production installer. It is an engineering template with documentation, Docker Compose files, diagnostics, API skeletons, and agent prompts for safe step-by-step deployment.

Principles:

- **Privacy first** — personal photos, videos, contacts, calendars, documents, and backup manifests must not be sent to an external LLM.
- **LAN/VPN only** — Nextcloud, Immich, LLM Gateway, and SSH are not exposed directly to the public internet.
- **Small steps** — every deployment block is verified before moving to the next.
- **No real secrets in git** — `.env`, tokens, API keys, private keys, dumps, and personal data are excluded from the repository.
- **No local LLM on Jetson Nano in Stage 1** — Jetson Nano is a home server, not an LLM inference node.

---

## Стек / Stack

| Область / Area | Компонент / Component | Версия / Version | Роль / Role |
|---|---|---|---|
| Файлы и документы / Files | Nextcloud | latest (apache) | File cloud, WebDAV, CalDAV, CardDAV |
| Фото и видео / Photos | Immich | latest | Photo/video archive with Android sync |
| Контакты/Календарь / Contacts | DAVx5 (Android client) | — | Sync Nextcloud Contacts & Calendar to Android |
| Базы данных / Databases | PostgreSQL | 16-alpine | Nextcloud DB + Immich DB (pgvecto-rs for Immich) |
| Кэш/Очереди / Cache | Redis | 7-alpine | Nextcloud cache + Immich job queue |
| Локальный NAS / Local NAS | Samba (docker-samba) | crazymax/samba | SMB/CIFS for Windows/Android file managers |
| Бэкапы / Backups | restic + pg\_dump | — | DB dumps and file snapshots |
| LLM-помощник / LLM assistant | DeepSeek API | deepseek-chat | Admin assistant via privacy filter |
| LLM-шлюз / LLM Gateway | FastAPI LLM Gateway | — | Privacy shim, redaction, mock mode |
| Мониторинг / Monitoring | Netdata + Uptime Kuma + Portainer | — | Observability stack (запланировано / planned) |
| Android backup API | services/backup-api | — | Stage 2 placeholder |

---

## Требования / Prerequisites

> 🇷🇺 Русский

**Железо:**

| Компонент | Рекомендация |
|---|---|
| Вычислительный узел | NVIDIA Jetson Nano Developer Kit (2 GB или 4 GB) |
| Системный диск | microSD 64 GB или больше (Class 10 / A2) |
| Диск данных | USB HDD с отдельным питанием |
| Сеть | Домашняя LAN; роутер со статическим DHCP lease для Jetson |
| Внешний доступ | VPN / mesh VPN (WireGuard или Tailscale) |

**Программное обеспечение на Jetson:**

- L4T / JetPack 4.x (Ubuntu 18.04 на Jetson)
- Docker Engine 20.10+
- Docker Compose v2 (`docker compose version` — без дефиса)

**На рабочей машине:**

- Git
- SSH-клиент

> 🇬🇧 English

**Hardware:**

| Component | Recommendation |
|---|---|
| Compute node | NVIDIA Jetson Nano Developer Kit (2 GB or 4 GB) |
| System drive | microSD 64 GB or larger (Class 10 / A2) |
| Data drive | USB HDD with external power supply |
| Network | Home LAN; router with static DHCP lease for Jetson |
| External access | VPN / mesh VPN (WireGuard or Tailscale) |

**Software on Jetson:**

- L4T / JetPack 4.x (Ubuntu 18.04 on Jetson)
- Docker Engine 20.10+
- Docker Compose v2 (`docker compose version` — no hyphen)

**On your workstation:**

- Git
- SSH client

---

## Быстрый старт / Quick Start

> 🇷🇺 Русский

```bash
# 1. Клонировать репозиторий
git clone https://github.com/AlexeyBorovskoy/nasa-home-cloud.git
cd nasa-home-cloud

# 2. Создать локальный env-файл из шаблона
cp config/.env.example config/.env
chmod 600 config/.env

# 3. Заполнить все placeholder-значения
#    (пароли, пути к дискам, ключи DeepSeek и т.д.)
nano config/.env

# 4. Проверить синтаксис Compose перед первым запуском
docker compose -f docker/compose/docker-compose.stage1.yml --env-file config/.env config

# 5. Запустить аппаратный аудит на целевом Jetson Nano
./scripts/diagnostics/hardware_audit.sh

# 6. Развернуть Nextcloud (после подготовки хранилища)
docker compose -f docker/compose/docker-compose.nextcloud.yml --env-file config/.env up -d

# 7. Проверить состояние контейнеров
docker compose -f docker/compose/docker-compose.nextcloud.yml ps
docker compose -f docker/compose/docker-compose.nextcloud.yml logs --tail 50
```

Полный порядок развёртывания по этапам: [docs/14_TEST_PLAN.md](docs/14_TEST_PLAN.md).

Если Jetson ещё не загружен — сначала подготовьте microSD: [docs/01A_JETSON_SD_BOOTSTRAP.md](docs/01A_JETSON_SD_BOOTSTRAP.md).

> 🇬🇧 English

```bash
# 1. Clone the repository
git clone https://github.com/AlexeyBorovskoy/nasa-home-cloud.git
cd nasa-home-cloud

# 2. Create a local env file from the template
cp config/.env.example config/.env
chmod 600 config/.env

# 3. Fill in all placeholder values
#    (passwords, storage paths, DeepSeek API key, etc.)
nano config/.env

# 4. Validate Compose syntax before the first run
docker compose -f docker/compose/docker-compose.stage1.yml --env-file config/.env config

# 5. Run hardware audit on the target Jetson Nano
./scripts/diagnostics/hardware_audit.sh

# 6. Deploy Nextcloud (after preparing storage)
docker compose -f docker/compose/docker-compose.nextcloud.yml --env-file config/.env up -d

# 7. Check container status
docker compose -f docker/compose/docker-compose.nextcloud.yml ps
docker compose -f docker/compose/docker-compose.nextcloud.yml logs --tail 50
```

Full staged deployment order: [docs/14_TEST_PLAN.md](docs/14_TEST_PLAN.md).

If Jetson has not booted yet — prepare the microSD card first: [docs/01A_JETSON_SD_BOOTSTRAP.md](docs/01A_JETSON_SD_BOOTSTRAP.md).

---

## Конфигурация / Configuration

> 🇷🇺 Русский

Все переменные окружения хранятся в `config/.env` (не коммитится). Шаблон со всеми ключами — `config/.env.example`.

Ключевые переменные:

```bash
# Хранилище
STORAGE_ROOT=/mnt/storage
NEXTCLOUD_DATA=/mnt/storage/nextcloud/data
IMMICH_UPLOAD_LOCATION=/mnt/storage/immich/library
BACKUP_ROOT=/mnt/storage/backups

# Базы данных
POSTGRES_NEXTCLOUD_PASSWORD=changeme
IMMICH_DB_PASSWORD=changeme

# LLM Gateway
DEEPSEEK_API_KEY=sk-...
DEEPSEEK_MODEL=deepseek-chat
DEEPSEEK_REASONER_MODEL=deepseek-reasoner

# Immich — отключить ML до нагрузочных тестов на Jetson
IMMICH_DISABLE_MACHINE_LEARNING=true
```

Политика конфиденциальности для LLM: `config/llm-policy.yaml`.

Никогда не коммитьте реальный `config/.env`. Он добавлен в `.gitignore`.

> 🇬🇧 English

All environment variables live in `config/.env` (not committed). The public template with all keys is `config/.env.example`.

Key variables:

```bash
# Storage
STORAGE_ROOT=/mnt/storage
NEXTCLOUD_DATA=/mnt/storage/nextcloud/data
IMMICH_UPLOAD_LOCATION=/mnt/storage/immich/library
BACKUP_ROOT=/mnt/storage/backups

# Databases
POSTGRES_NEXTCLOUD_PASSWORD=changeme
IMMICH_DB_PASSWORD=changeme

# LLM Gateway
DEEPSEEK_API_KEY=sk-...
DEEPSEEK_MODEL=deepseek-chat
DEEPSEEK_REASONER_MODEL=deepseek-reasoner

# Immich — disable ML until Jetson load tests pass
IMMICH_DISABLE_MACHINE_LEARNING=true
```

LLM privacy policy: `config/llm-policy.yaml`.

Never commit your real `config/.env`. It is listed in `.gitignore`.

---

## Архитектура / Architecture

> 🇷🇺 Русский / 🇬🇧 English

```
Android-телефоны / Android phones
Ноутбуки / Laptops
        |
        |  Только LAN / VPN  —  LAN / VPN only
        |
        v
  [ Домашний роутер / Home router ]
        |
        v
  [ Jetson Nano + USB HDD ]
        |
        +-- Nextcloud (port 8080)
        |     +-- PostgreSQL 16
        |     +-- Redis 7
        |
        +-- Immich (port 2283)
        |     +-- PostgreSQL 16 + pgvecto-rs
        |     +-- Redis 7
        |
        +-- LLM Gateway / FastAPI (port 8090)
        |     +-- [ DeepSeek API ] (external, privacy-filtered)
        |
        +-- Samba / SFTP  [запланировано / planned — Stage 1A]
        |
        +-- Backup jobs
              +-- pg_dump  -->  /mnt/storage/backups/database-dumps
              +-- restic   -->  /mnt/storage/backups/restic-repo

/mnt/storage  (USB HDD с отдельным питанием / USB HDD with external power)
  ├── nextcloud/data
  ├── immich/library
  ├── db/
  │   ├── nextcloud-postgres
  │   └── immich-postgres
  ├── backups/
  │   ├── database-dumps
  │   └── restic-repo
  └── samba/
```

Mermaid-диаграмма: [archtectura_nasa.md](archtectura_nasa.md).

Сетевые правила, порты, VPN: [docs/05_NETWORKING_VPN.md](docs/05_NETWORKING_VPN.md).

Архитектурные решения (ADR): [docs/decisions/](docs/decisions/).

Docker Compose файлы:

| Файл / File | Назначение / Purpose |
|---|---|
| `docker/compose/docker-compose.stage1.yml` | Полный Stage 1 stack / Full Stage 1 stack |
| `docker/compose/docker-compose.nextcloud.yml` | Изолированный Nextcloud / Nextcloud standalone |
| `docker/compose/docker-compose.immich.yml` | Изолированный Immich / Immich standalone |
| `docker/compose/docker-compose.llm-gateway.yml` | Изолированный LLM Gateway / LLM Gateway standalone |

---

## Этапы / Stages

| Этап / Stage | Содержание / Content | Статус / Status |
|---|---|---|
| Stage 0 | Подготовка microSD, первый boot, SSH / microSD prep, first boot, SSH | описано / documented |
| Stage 1A | Hardware audit, storage, Samba/SFTP | спроектировано / designed |
| Stage 1B | Nextcloud | compose-черновик / compose draft |
| Stage 1C | Immich (Jetson-safe mode) | compose-черновик / compose draft |
| Stage 1D | DeepSeek LLM Gateway | FastAPI skeleton ready |
| Stage 1E | Backup / restore (restic + pg\_dump) | scripts draft ready |
| Stage 2 | Android backup/restore client API | архитектура / architecture only |
| Stage 3 | Analytics, RAG, fallback LLM providers | будущее / future |

Подробный план тестирования: [docs/14_TEST_PLAN.md](docs/14_TEST_PLAN.md).

---

## Мониторинг / Monitoring

> 🇷🇺 Русский

Стек мониторинга задокументирован и подготовлен к развёртыванию:

- **Netdata** — real-time метрики хоста и контейнеров.
- **Uptime Kuma** — мониторинг доступности сервисов.
- **Portainer** — управление Docker-контейнерами через web UI.

Документация: [docs/17_MONITORING_OBSERVABILITY.md](docs/17_MONITORING_OBSERVABILITY.md) _(планируется / planned)_.

Текущий runbook: [docs/13_MONITORING_RUNBOOK.md](docs/13_MONITORING_RUNBOOK.md).

> 🇬🇧 English

A monitoring stack is documented and ready for deployment:

- **Netdata** — real-time host and container metrics.
- **Uptime Kuma** — service availability monitoring.
- **Portainer** — Docker container management via web UI.

Documentation: [docs/17_MONITORING_OBSERVABILITY.md](docs/17_MONITORING_OBSERVABILITY.md) _(planned)_.

Current runbook: [docs/13_MONITORING_RUNBOOK.md](docs/13_MONITORING_RUNBOOK.md).

---

## Документация / Documentation

| Файл / File | Описание / Description |
|---|---|
| [docs/00_OVERVIEW.md](docs/00_OVERVIEW.md) | Обзор концепции / Project concept overview |
| [docs/01_HARDWARE_AUDIT.md](docs/01_HARDWARE_AUDIT.md) | Аппаратный аудит Jetson Nano / Hardware audit guide |
| [docs/01A_JETSON_SD_BOOTSTRAP.md](docs/01A_JETSON_SD_BOOTSTRAP.md) | Подготовка microSD, первый boot / microSD bootstrap recipe |
| [docs/02_REQUIREMENTS.md](docs/02_REQUIREMENTS.md) | Требования к железу, ПО, сети / Hardware and software requirements |
| [docs/03_ARCHITECTURE.md](docs/03_ARCHITECTURE.md) | Архитектурная схема / Architecture overview |
| [docs/04_STORAGE_DESIGN.md](docs/04_STORAGE_DESIGN.md) | Дизайн хранилища (USB HDD, mount, fstab) / Storage design |
| [docs/05_NETWORKING_VPN.md](docs/05_NETWORKING_VPN.md) | LAN/VPN-модель, WireGuard, порты / Networking and VPN |
| [docs/06_NEXTCLOUD_DESIGN.md](docs/06_NEXTCLOUD_DESIGN.md) | Дизайн Nextcloud / Nextcloud deployment design |
| [docs/07_IMMICH_DESIGN.md](docs/07_IMMICH_DESIGN.md) | Дизайн Immich (Jetson-safe) / Immich deployment design |
| [docs/08_LLM_GATEWAY_DEEPSEEK.md](docs/08_LLM_GATEWAY_DEEPSEEK.md) | LLM Gateway и DeepSeek API / LLM Gateway and DeepSeek API |
| [docs/09_ANDROID_STAGE2_ARCHITECTURE.md](docs/09_ANDROID_STAGE2_ARCHITECTURE.md) | Android Stage 2 архитектура / Android backup client architecture |
| [docs/10_SECURITY_PRIVACY.md](docs/10_SECURITY_PRIVACY.md) | Безопасность и приватность / Security and privacy |
| [docs/11_SECRETS_POLICY.md](docs/11_SECRETS_POLICY.md) | Политика секретов / Secrets management policy |
| [docs/12_BACKUP_RESTORE.md](docs/12_BACKUP_RESTORE.md) | Backup и restore workflow / Backup and restore |
| [docs/13_MONITORING_RUNBOOK.md](docs/13_MONITORING_RUNBOOK.md) | Runbook и мониторинг / Monitoring runbook |
| [docs/14_TEST_PLAN.md](docs/14_TEST_PLAN.md) | План тестирования по этапам / Staged test plan |
| [docs/15_ALTERNATIVES_REVIEW.md](docs/15_ALTERNATIVES_REVIEW.md) | Обзор альтернативных решений / Alternatives review |
| [docs/16_GITHUB_PUBLICATION.md](docs/16_GITHUB_PUBLICATION.md) | Публикация на GitHub / GitHub publication guide |
| [docs/decisions/ADR-0001-nextcloud-immich-deepseek.md](docs/decisions/ADR-0001-nextcloud-immich-deepseek.md) | ADR-0001: выбор стека / ADR-0001: stack selection |
| [docs/plans/README.md](docs/plans/README.md) | Индекс стратегических планов / Strategic plans index |
| [AGENTS.md](AGENTS.md) | Правила для Codex/агентов / Codex and agent onboarding |
| [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) | Зафиксированные решения и ограничения / Fixed decisions and constraints |
| [archtectura_nasa.md](archtectura_nasa.md) | Полная архитектурная карта (Mermaid) / Full architecture map with Mermaid |

---

## Безопасность / Security

> 🇷🇺 Русский

- Сообщить об уязвимости: откройте private security advisory на GitHub или свяжитесь с владельцем репозитория напрямую.
- Никогда не коммитьте реальные `.env`, ключи, токены, дампы и персональные данные.
- LLM Gateway в Stage 1 блокирует отправку фото, видео, контактов, ключей и личных документов во внешний API.

Проверка репозитория перед push:

```bash
./scripts/security/check_no_secrets.sh
find . -name '.env' -o -name '*.key' -o -name '*.pem' -o -name '*.p12'
```

CI проверяет секреты автоматически: `.github/workflows/secrets-check.yml`.

Полная политика: [SECURITY.md](SECURITY.md) | [docs/10_SECURITY_PRIVACY.md](docs/10_SECURITY_PRIVACY.md) | [docs/11_SECRETS_POLICY.md](docs/11_SECRETS_POLICY.md).

> 🇬🇧 English

- To report a vulnerability: open a private security advisory on GitHub or contact the repository owner directly.
- Never commit real `.env` files, keys, tokens, database dumps, or personal data.
- LLM Gateway in Stage 1 blocks sending photos, videos, contacts, keys, and personal documents to the external API.

Check the repository before pushing:

```bash
./scripts/security/check_no_secrets.sh
find . -name '.env' -o -name '*.key' -o -name '*.pem' -o -name '*.p12'
```

CI runs the secrets check automatically: `.github/workflows/secrets-check.yml`.

Full policy: [SECURITY.md](SECURITY.md) | [docs/10_SECURITY_PRIVACY.md](docs/10_SECURITY_PRIVACY.md) | [docs/11_SECRETS_POLICY.md](docs/11_SECRETS_POLICY.md).

---

## Текущие ограничения / Known Limitations

> 🇷🇺 Русский

- Проект ещё не проверен на реальном Jetson Nano в production.
- `backup_databases.sh` — placeholder; реализуется после первого реального запуска контейнеров.
- `IMMICH_DISABLE_MACHINE_LEARNING=true` задана в `.env.example`, но ещё не передана в compose — нужно сделать перед первым запуском Immich на Jetson.
- `config/llm-policy.yaml` описывает целевую политику; часть лимитов ещё не enforced в коде LLM Gateway.
- `services/backup-api` — Stage 2 placeholder, не production backup-сервис.
- Samba и reverse proxy (HTTPS) — запланированы на Stage 1A, ещё не развёрнуты.
- Локальные Jetson-материалы хранятся в `external_docs/jatson` и не коммитятся; см. [docs/references/JETSON_LOCAL_ASSETS.md](docs/references/JETSON_LOCAL_ASSETS.md).

> 🇬🇧 English

- The project has not been tested on a real Jetson Nano in production yet.
- `backup_databases.sh` is a placeholder; it will be implemented after the first real container run.
- `IMMICH_DISABLE_MACHINE_LEARNING=true` is defined in `.env.example` but not yet wired into the compose file — this must be done before the first Immich run on Jetson.
- `config/llm-policy.yaml` describes the target policy; some limits are not yet enforced in LLM Gateway code.
- `services/backup-api` is a Stage 2 placeholder, not a production backup service.
- Samba and reverse proxy (HTTPS) are planned for Stage 1A and not yet deployed.
- Local Jetson assets are stored in `external_docs/jatson` and are not committed; see [docs/references/JETSON_LOCAL_ASSETS.md](docs/references/JETSON_LOCAL_ASSETS.md).

---

## Roadmap

| Версия / Version | Содержание / Content |
|---|---|
| v0.1 | Документация и безопасный bootstrap / Documentation and secure bootstrap |
| v0.2 | Hardware audit и storage scripts / Hardware audit and storage scripts |
| v0.3 | Проверенный Nextcloud deployment / Verified Nextcloud deployment |
| v0.4 | Проверенный Immich с Jetson-safe настройками / Verified Immich Jetson-safe config |
| v0.5 | Backup/restore workflow |
| v0.6 | LLM Gateway policy enforcement |
| v0.7 | Android Stage 2 API draft |
| v1.0 | Проверенная установка на Jetson Nano / Verified install on Jetson Nano |

---

## Вклад / Contributing

> 🇷🇺 Русский

Вклад приветствуется. Прочитайте [CONTRIBUTING.md](CONTRIBUTING.md) и [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) перед тем, как открывать pull request.

Правила:
- Не коммитьте секреты и персональные данные.
- Предпочитайте небольшие pull request с документацией.
- Сохраняйте Stage 1 безопасным: нет прямого публичного доступа к сервисам.

Хорошие первые задачи:
- Улучшить hardware audit script.
- Добавить заметки для Raspberry Pi 4/5.
- Добавить CI-валидацию shell-скриптов (shellcheck).
- Синхронизировать архитектурные документы с текущим деревом проекта.

> 🇬🇧 English

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before opening a pull request.

Rules:
- Do not commit secrets or personal data.
- Prefer small pull requests with documentation.
- Keep Stage 1 safe: no direct public port exposure by default.

Good first issues:
- Improve the hardware audit script.
- Add Raspberry Pi 4/5 notes.
- Add CI shellcheck validation.
- Synchronize architecture documents with the current project tree.

---

## Лицензия / License

MIT — см. [LICENSE](LICENSE) / see [LICENSE](LICENSE).
