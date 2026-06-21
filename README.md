# NASA Home Cloud
### _Old hardware should live_ · _Старое железо должно жить_

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Stage](https://img.shields.io/badge/Stage-1%20Complete-brightgreen)](docs/14_TEST_PLAN.md)
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
- [Что работает прямо сейчас / What's running](#что-работает-прямо-сейчас--whats-running)
- [Архитектура / Architecture](#архитектура--architecture)
- [Стек / Stack](#стек--stack)
- [Требования / Prerequisites](#требования--prerequisites)
- [Быстрый старт / Quick Start](#быстрый-старт--quick-start)
- [Конфигурация / Configuration](#конфигурация--configuration)
- [Этапы / Stages](#этапы--stages)
- [Документация / Documentation](#документация--documentation)
- [Безопасность / Security](#безопасность--security)
- [Вклад / Contributing](#вклад--contributing)
- [Лицензия / License](#лицензия--license)

---

## О проекте / About

> 🇷🇺 Русский

**NASA Home Cloud** — проект домашней семейной облачной платформы на базе **NVIDIA Jetson Nano 4 GB + USB HDD**. Цель — заменить Google/Xiaomi Cloud собственной инфраструктурой: файлы, фотоархив, локальный NAS, резервное копирование и приватный LLM-ассистент.

Это не production-инсталлятор в один клик. Это инженерный шаблон: документация, Docker Compose, диагностические скрипты, systemd-юниты и промпты для агентов, позволяющие разворачивать платформу малыми проверяемыми шагами.

Принципы:

- **Приватность прежде всего** — фото, видео, контакты, календарь и резервные копии не покидают домашнюю сеть.
- **Только LAN + обратный SSH-тоннель** — сервисы недоступны напрямую из интернета; CGNAT обходится через VPS.
- **Малые шаги** — каждый блок разворачивается отдельно и проверяется перед следующим.
- **Без секретов в git** — реальные `.env`, токены, ключи и персональные данные не попадают в репозиторий.
- **Устойчивость** — `restart: always`, mem_limit, Docker healthchecks, ежедневный Telegram-отчёт.

> 🇬🇧 English

**NASA Home Cloud** is a Codex-ready blueprint for a private family cloud on **NVIDIA Jetson Nano 4 GB + USB HDD**. It replaces Google/Xiaomi Cloud with self-hosted files, photo archive, local NAS, backups, and a privacy-controlled LLM admin assistant.

This is not a one-command production installer. It is an engineering template with documentation, Docker Compose files, diagnostics, systemd units, and agent prompts for safe step-by-step deployment.

Principles:

- **Privacy first** — photos, videos, contacts, calendars, and backups never leave the home network.
- **LAN + reverse SSH tunnel only** — services are not exposed directly to the internet; CGNAT is bypassed via VPS relay.
- **Small steps** — every deployment block is verified before moving to the next.
- **No real secrets in git** — `.env`, tokens, API keys, and personal data are excluded from the repository.
- **Resilience** — `restart: always`, mem_limit, Docker healthchecks, daily Telegram health report.

---

## Что работает прямо сейчас / What's running

> Состояние на 2026-06-21 / State as of 2026-06-21 · **Stage 1 полностью развёрнут**

| Сервис / Service | Порт / Port | Доступ / Access | Статус / Status |
|---|---|---|---|
| Nextcloud | 8080 | VPS `193.8.215.130:8080` + LAN | ✅ Live |
| Immich | 2283 | VPS `193.8.215.130:2283` + LAN | ✅ Live |
| LLM Gateway | 8090 | VPS `193.8.215.130:8090` + LAN | ✅ Live |
| nasa-api (Swagger) | 8099 | LAN `192.168.0.50:8099/docs` | ✅ Live |
| Samba NAS | 445/139 | LAN only (192.168.0.0/24) | ✅ Live |
| Netdata | 19999 | LAN `192.168.0.50:19999` | ✅ Live |
| Uptime Kuma | 3001 | LAN `192.168.0.50:3001` | ✅ Live |
| Portainer | 9000 | LAN `192.168.0.50:9000` | ✅ Live |
| VPS nginx reverse proxy | — | VPS 193.8.215.130 | ✅ Live |
| autossh tunnel | — | Jetson → VPS persistent | ✅ Live |
| Telegram daily report | — | Bot → personal chat | ✅ Live (09:00) |
| Android backup API | — | — | 🔜 Stage 2 |

---

## Архитектура / Architecture

```
Интернет / Internet
        |
        | (публичный IP / public IP)
        v
  [ VPS 193.8.215.130 — Вена / Vienna ]
        |
        |  nginx (host network, docker)
        |  :8080  → 127.0.0.1:18080 → tunnel → Jetson:8080  (Nextcloud)
        |  :2283  → 127.0.0.1:12283 → tunnel → Jetson:2283  (Immich)
        |  :8090  → 127.0.0.1:18090 → tunnel → Jetson:8090  (LLM Gateway)
        |  :10022 → tunnel → Jetson:22                       (SSH управление)
        |
        |  ↑ autossh reverse SSH tunnel (обход CGNAT)
        |
  [ Домашний роутер / Home router ]
        |  (статический DHCP: 192.168.0.50)
        v
  [ Jetson Nano 4GB · Ubuntu 18.04 · 192.168.0.50 ]
        |
        +-- Nextcloud (8080) · PostgreSQL 16 · Redis 7
        |
        +-- Immich (2283) · PostgreSQL 16 + pgvecto-rs · Redis 7
        |
        +-- LLM Gateway / FastAPI (8090)
        |     +-- [ DeepSeek API ] — privacy-filtered
        |
        +-- nasa-api / FastAPI (8099) · Swagger UI /docs
        |     · /v1/metrics · /v1/containers · /v1/logs · POST /v1/report/now
        |
        +-- Samba NAS (445, LAN only)
        |     iptables: разрешён только 192.168.0.0/24
        |
        +-- Netdata (19999)   — система, Docker, температура Jetson
        +-- Uptime Kuma (3001) — HTTP uptime + Telegram alerts
        +-- Portainer (9000)   — Docker management UI
        |
        +-- systemd: nasa-tunnel.service (autossh, restart=always)
        +-- systemd: nasa-daily-report-telegram.timer (09:00 ежедневно)
        +-- systemd: SMART мониторинг HDD (6h timer)

/mnt/storage  (USB HDD, отдельное питание)
  ├── nextcloud/data
  ├── immich/library
  ├── db/
  │   ├── nextcloud-postgres
  │   └── immich-postgres
  ├── backups/
  │   ├── database-dumps
  │   └── restic-repo
  └── samba/public
```

**Docker Compose файлы:**

| Файл / File | Назначение / Purpose |
|---|---|
| `docker/compose/docker-compose.nextcloud.yml` | Nextcloud + PostgreSQL + Redis |
| `docker/compose/docker-compose.immich.yml` | Immich + PostgreSQL + Redis |
| `docker/compose/docker-compose.llm-gateway.yml` | LLM Gateway (FastAPI) |
| `docker/compose/docker-compose.samba.yml` | Samba NAS (ARM64, SMB2+) |
| `docker/compose/docker-compose.monitoring.yml` | Netdata + Uptime Kuma + Portainer |
| `docker/compose/docker-compose.nasa-api.yml` | nasa-api (FastAPI, Swagger, JSON logs) |
| `docker/vps/docker-compose.yml` | nginx reverse proxy на VPS (`network_mode: host`) |

---

## Стек / Stack

| Область / Area | Компонент | Версия | Роль |
|---|---|---|---|
| Файлы и документы | Nextcloud | latest (apache) | File cloud, WebDAV, CalDAV, CardDAV |
| Фото и видео | Immich | release | Photo/video archive, Android sync |
| Базы данных | PostgreSQL | 16 / pgvecto-rs | Nextcloud DB + Immich DB |
| Кэш / Очереди | Redis | 7-alpine | Nextcloud cache + Immich queue |
| Локальный NAS | Samba (crazymax/samba) | latest ARM64 | SMB2+ для Windows/Android/macOS |
| LLM-шлюз | FastAPI LLM Gateway | — | Privacy shim, редакция персданных |
| LLM API | DeepSeek API | deepseek-chat | Помощник администратора |
| Admin API | nasa-api (FastAPI) | — | Метрики, логи, контейнеры, Swagger UI |
| Тоннель | autossh + systemd | — | Reverse SSH через CGNAT → VPS |
| VPS прокси | nginx:alpine | — | Reverse proxy на публичный порт |
| Мониторинг | Netdata | latest ARM64 | CPU, RAM, Disk, Docker, Jetson temp |
| Uptime | Uptime Kuma | 1 | HTTP uptime + Telegram/email алерты |
| Docker UI | Portainer CE | latest | Web UI для Docker management |
| Ежедневный отчёт | bash + SSH relay + Telegram | — | 09:00 отчёт о здоровье кластера |
| Тестирование | goss v0.4.9 (ARM64) | — | Infrastructure state tests |
| Здоровье системы | systemd timers + SMART | — | Диагностика 6ч + HDD health |
| Бэкапы | restic + pg\_dump | — | DB dumps + файловые снимки |
| Android backup API | services/backup-api | — | Stage 2 placeholder |

---

## Требования / Prerequisites

**Железо / Hardware:**

| Компонент | Рекомендация |
|---|---|
| Вычислительный узел | NVIDIA Jetson Nano Developer Kit (4 GB) |
| Системный диск | microSD 64 GB (Class 10 / A2) |
| Диск данных | USB HDD с отдельным питанием |
| Сеть | Домашняя LAN, статический DHCP lease для Jetson |
| Внешний доступ | VPS (любой; проверено на Ubuntu 24.04, 1 vCPU, 2 GB RAM) |

**ПО на Jetson / Software on Jetson:**

- L4T / JetPack 4.x (Ubuntu 18.04)
- Docker Engine 20.10+, Docker Compose v2
- autossh (`apt install autossh`)
- curl (`apt install curl`)
- SSH-ключ для VPS в `~/.ssh/`

**ПО на VPS:**

- Docker + Docker Compose v2
- UFW: открыть порты 8080, 2283, 8090 (и 22 для SSH)
- SSH: разрешить вход от Jetson-ключа

---

## Быстрый старт / Quick Start

### 1. Клонировать / Clone

```bash
git clone https://github.com/AlexeyBorovskoy/Nasa_home.git
cd Nasa_home
cp config/.env.example config/.env
chmod 600 config/.env
nano config/.env   # заполнить пароли, пути, DeepSeek API key
```

### 2. Настроить VPS / Setup VPS

```bash
# На VPS:
mkdir -p /opt/nasa
# скопировать docker/vps/ из репозитория
cd /opt/nasa && docker compose up -d
```

### 3. Настроить тоннель на Jetson / Setup tunnel on Jetson

```bash
# На Jetson:
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@<VPS_IP>

sudo cp systemd/nasa-tunnel.service /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable --now nasa-tunnel.service
```

### 4. Запустить сервисы / Start services

```bash
# На Jetson:
cd ~/nasa/docker/compose

docker compose -f docker-compose.nextcloud.yml   --env-file ../../config/.env up -d
docker compose -f docker-compose.immich.yml      --env-file ../../config/.env up -d
docker compose -f docker-compose.llm-gateway.yml --env-file ../../config/.env up -d
docker compose -f docker-compose.monitoring.yml  --env-file ../../config/.env up -d
docker compose -f docker-compose.nasa-api.yml    --env-file ../../config/.env up -d
```

### 5. Настроить Telegram-отчёты / Setup Telegram reports

```bash
# На Jetson:
sudo mkdir -p /etc/nasa-monitor /var/log/nasa-monitor
sudo cp scripts/monitoring/nasa-daily-report.sh /usr/local/sbin/
sudo cp scripts/monitoring/nasa-send-report-telegram.sh /usr/local/sbin/
sudo chmod +x /usr/local/sbin/nasa-*.sh

# Создать /etc/nasa-monitor/telegram.env (не коммитить!)
sudo tee /etc/nasa-monitor/telegram.env <<EOF
TELEGRAM_BOT_TOKEN=<your-token>
TELEGRAM_CHAT_ID=<your-chat-id>
EOF
sudo chmod 600 /etc/nasa-monitor/telegram.env

# Установить systemd таймер (09:00 ежедневно)
sudo cp systemd/nasa-daily-report-telegram.{service,timer} /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now nasa-daily-report-telegram.timer
```

### 6. Проверить / Verify

```bash
# Локально на Jetson:
curl -sf http://localhost:8080/status.php         # Nextcloud → {"installed":true,...}
curl -sf http://localhost:2283/api/server/ping    # Immich → {"res":"pong"}
curl -sf http://localhost:8090/health             # LLM Gateway → {"status":"ok"}
curl -sf http://localhost:8099/healthcheck        # nasa-api → {"status":"ok"}
curl -sf http://localhost:19999/api/v1/info       # Netdata → {...}

# Через goss:
goss -g tests/goss/goss.yaml validate --format tap

# Swagger UI: http://192.168.0.50:8099/docs
```

Полный план тестирования: [docs/14_TEST_PLAN.md](docs/14_TEST_PLAN.md).  
Подготовка microSD: [docs/01A_JETSON_SD_BOOTSTRAP.md](docs/01A_JETSON_SD_BOOTSTRAP.md).

---

## Конфигурация / Configuration

Все переменные — в `config/.env` (не коммитится). Шаблон: `config/.env.example`.

```bash
# Хранилище
STORAGE_ROOT=/mnt/storage
NEXTCLOUD_DATA=/mnt/storage/nextcloud/data
IMMICH_UPLOAD_LOCATION=/mnt/storage/immich/library

# Базы данных
NEXTCLOUD_DB_PASSWORD=changeme
IMMICH_DB_PASSWORD=changeme
REDIS_PASSWORD=changeme

# VPS tunnel
VPS_HOST=your.vps.ip
VPS_USER=root
VPS_SSH_KEY=/home/admin/.ssh/id_ed25519

# LLM Gateway
DEEPSEEK_API_KEY=sk-...
DEEPSEEK_MODEL=deepseek-chat
IMMICH_DISABLE_MACHINE_LEARNING=true   # обязательно для Jetson Nano
```

Никогда не коммитьте реальный `config/.env`. Он в `.gitignore`.

---

## Этапы / Stages

| Этап / Stage | Содержание / Content | Статус / Status |
|---|---|---|
| Stage 0 | microSD, первый boot, SSH, USB device mode | ✅ Задокументировано |
| Stage 1A | Hardware audit, USB HDD setup, Samba NAS | ✅ **Развёрнут и работает** |
| Stage 1B | Nextcloud + PostgreSQL + Redis | ✅ **Развёрнут и работает** |
| Stage 1C | Immich (ML отключён для Jetson) | ✅ **Развёрнут и работает** |
| Stage 1D | LLM Gateway + DeepSeek | ✅ **Развёрнут и работает** |
| Stage 1E | VPS + reverse SSH tunnel (autossh) | ✅ **Работает, nginx на VPS** |
| Stage 1F | Мониторинг (Netdata, Uptime Kuma, Portainer) | ✅ **Развёрнут и работает** |
| Stage 1G | nasa-api (FastAPI, Swagger, JSON logs) + Telegram отчёт | ✅ **Развёрнут и работает** |
| Stage 1H | Resilience audit: healthchecks, mem_limit, goss | ✅ **Выполнено (8/10 findings fixed)** |
| Stage 2 | Android backup/restore client API | 📋 Архитектура |
| Stage 3 | Backup / restore (restic + pg\_dump) | 🔜 Скрипты-заготовки |
| Stage 4 | Analytics, RAG, fallback LLM providers | 📋 Будущее |

---

## Документация / Documentation

| Файл / File | Описание / Description |
|---|---|
| [docs/00_OVERVIEW.md](docs/00_OVERVIEW.md) | Обзор концепции / Project concept overview |
| [docs/01_HARDWARE_AUDIT.md](docs/01_HARDWARE_AUDIT.md) | Аппаратный аудит Jetson Nano |
| [docs/01A_JETSON_SD_BOOTSTRAP.md](docs/01A_JETSON_SD_BOOTSTRAP.md) | Подготовка microSD, первый boot |
| [docs/02_REQUIREMENTS.md](docs/02_REQUIREMENTS.md) | Требования к железу, ПО, сети |
| [docs/03_ARCHITECTURE.md](docs/03_ARCHITECTURE.md) | Архитектурная схема |
| [docs/04_STORAGE_DESIGN.md](docs/04_STORAGE_DESIGN.md) | Дизайн хранилища (USB HDD, mount, fstab) |
| [docs/05_NETWORKING_VPN.md](docs/05_NETWORKING_VPN.md) | LAN/VPN-модель, тоннели, порты |
| [docs/06_NEXTCLOUD_DESIGN.md](docs/06_NEXTCLOUD_DESIGN.md) | Дизайн Nextcloud |
| [docs/07_IMMICH_DESIGN.md](docs/07_IMMICH_DESIGN.md) | Дизайн Immich (Jetson-safe) |
| [docs/08_LLM_GATEWAY_DEEPSEEK.md](docs/08_LLM_GATEWAY_DEEPSEEK.md) | LLM Gateway и DeepSeek API |
| [docs/10_SECURITY_PRIVACY.md](docs/10_SECURITY_PRIVACY.md) | Безопасность и приватность |
| [docs/11_SECRETS_POLICY.md](docs/11_SECRETS_POLICY.md) | Политика секретов |
| [docs/12_BACKUP_RESTORE.md](docs/12_BACKUP_RESTORE.md) | Backup и restore workflow |
| [docs/13_MONITORING_RUNBOOK.md](docs/13_MONITORING_RUNBOOK.md) | Runbook мониторинга |
| [docs/14_TEST_PLAN.md](docs/14_TEST_PLAN.md) | План тестирования по этапам |
| [docs/17_MONITORING_OBSERVABILITY.md](docs/17_MONITORING_OBSERVABILITY.md) | Анализ инструментов мониторинга |
| [docs/19_NETWORK_INVENTORY.md](docs/19_NETWORK_INVENTORY.md) | Сетевой паспорт стенда |
| [docs/20_AGENT_OPERATING_MODEL.md](docs/20_AGENT_OPERATING_MODEL.md) | Операционная модель субагентов |
| [docs/21_LOGGING_API.md](docs/21_LOGGING_API.md) | JSON-логирование и nasa-api (Swagger) |
| [docs/22_AUDIT_RESILIENCE.md](docs/22_AUDIT_RESILIENCE.md) | Аудит надёжности: goss, shellcheck, итоги |
| [docs/plans/VPS_INTEGRATION_PLAN.md](docs/plans/VPS_INTEGRATION_PLAN.md) | План интеграции VPS + тоннель |
| [AGENTS.md](AGENTS.md) | Правила для Codex/агентов |
| [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) | Зафиксированные решения и ограничения |
| [archtectura_nasa.md](archtectura_nasa.md) | Полная архитектурная карта (Mermaid) |

---

## Безопасность / Security

- Не коммитьте реальные `.env`, ключи, токены, дампы и персональные данные.
- LLM Gateway блокирует отправку фото, видео, контактов и ключей во внешний API.
- Samba доступна только из локальной сети (`iptables`: 192.168.0.0/24 → 445/139).
- VPS nginx слушает публичные порты, но данные хранятся только на Jetson.
- Telegram-токен передаётся через зашифрованный SSH-туннель, не раскрывается в `ps aux` на VPS.

Проверка перед push:

```bash
./scripts/security/check_no_secrets.sh
```

CI автоматически проверяет секреты: `.github/workflows/secrets-check.yml`.

Полная политика: [SECURITY.md](SECURITY.md) · [docs/10_SECURITY_PRIVACY.md](docs/10_SECURITY_PRIVACY.md) · [docs/11_SECRETS_POLICY.md](docs/11_SECRETS_POLICY.md).

---

## Известные ограничения / Known Limitations

- HDD разбит на один раздел NTFS — для полноценного NAS нужен второй ext4-раздел. Требует физического подключения к ПК.
- `services/backup-api` — Stage 2 placeholder, не production backup-сервис.
- Immich работает без machine learning (`IMMICH_DISABLE_MACHINE_LEARNING=true`) — Jetson Nano 4 GB с ML не тестировался.
- VPS IP может меняться — при смене обновить `VPS_HOST` в `/etc/nasa-monitor/nasa-monitor.env` на Jetson и перезапустить `nasa-tunnel.service`.
- Docker 20.10.7 (JetPack 4.x) — устаревший. Обновление нетривиально из-за зависимостей NVIDIA runtime. Для home lab допустимо: все сервисы LAN-only, untrusted images не запускаются.
- HTTPS для VPS nginx — Let's Encrypt не настроен (нет доменного имени).

---

## Вклад / Contributing

Вклад приветствуется. Прочитайте [CONTRIBUTING.md](CONTRIBUTING.md) перед тем, как открывать pull request.

Правила:
- Не коммитьте секреты и персональные данные.
- Предпочитайте небольшие PR с документацией.
- Stage 1 должен оставаться безопасным: нет прямого публичного доступа к сервисам.

Хорошие первые задачи:
- Добавить заметки для Raspberry Pi 4/5 (аналогичная архитектура, без JetPack).
- Реализовать `backup_databases.sh` с реальным тестом восстановления (`pg_dump` + restic).
- Добавить HTTPS (Let's Encrypt) для VPS nginx.
- Настроить Netdata Telegram alerts (`/etc/netdata/health_alarm_notify.conf`).
- Добавить CI shellcheck для всех bash-скриптов в `scripts/`.

---

## Лицензия / License

MIT — см. [LICENSE](LICENSE).
