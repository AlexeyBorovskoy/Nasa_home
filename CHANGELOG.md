# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

## [1.3.1] — 2026-06-21 · Phase 1 ops tasks

### Added / Добавлено

- **`systemd/nasa-backup.{service,timer}`**: systemd timer for daily automated
  `pg_dump` at 03:00 (±15 min randomized delay); `Persistent=true` so missed
  runs are retried on next boot
- **`scripts/backup/install_backup_timer.sh`**: one-command installer — copies
  units, patches `NASA_PROJECT_DIR`, calls `daemon-reload`, enables and starts timer
- **`docs/13_MONITORING_RUNBOOK.md` §12-14**: added operational setup sections:
  backup timer install & verify, Uptime Kuma initial monitor list (5 services),
  Netdata Telegram alerts config via `docker exec`

## [1.3.0] — 2026-06-21 · Stage 1G + 1H complete

### Added / Добавлено

- **Monitoring stack deployed** (Stage 1F): Netdata (19999), Uptime Kuma (3001), Portainer (9000)
  running on Jetson via `docker-compose.monitoring.yml`
- **nasa-api** (Stage 1G): FastAPI service on port 8099 with Swagger UI at `/docs`
  — endpoints: `/v1/metrics`, `/v1/containers`, `/v1/logs`, `POST /v1/report/now`
  — pydantic-settings config, JSON structured logging (RotatingFileHandler 10 MB × 5)
  — `docker/compose/docker-compose.nasa-api.yml`
- **Telegram daily health report** (09:00): `scripts/monitoring/nasa-daily-report.sh`
  collects RAM, CPU, disk, container states, HTTP checks; sent via VPS SSH relay
  (`scripts/monitoring/nasa-send-report-telegram.sh`)
  — systemd timer: `nasa-daily-report-telegram.{service,timer}`
- **Docker healthchecks** added to all 10 containers:
  Nextcloud (`curl /status.php`), nextcloud-db/immich-db (`pg_isready`),
  nextcloud-redis/immich-redis (`redis-cli ping` with auth),
  immich-server (`curl /api/server/ping`), llm-gateway/nasa-api (`python3 urllib`),
  netdata (`curl /api/v1/info`), uptime-kuma (`extra/healthcheck`),
  portainer (`disable: true` — scratch image, no shell)
- **`depends_on: condition: service_healthy`** for nextcloud and immich stacks
  — containers wait for DB + Redis to be healthy before starting
- **`mem_limit`** added to all remaining containers:
  llm-gateway 256m, nasa-api 128m, netdata 256m, uptime-kuma 128m, portainer 128m
- **`restart: always`** applied to llm-gateway, nasa-api, and all monitoring services
- **`NETDATA_UPDATE_EVERY=5`** — reduces Netdata CPU from 19.5% to ~4%
- **goss v0.4.9 spec**: `tests/goss/goss.yaml` — 34 tests (ports, services, files, HTTP)
- **docs/21_LOGGING_API.md**: bilingual documentation for logging subsystem and nasa-api
- **docs/22_AUDIT_RESILIENCE.md**: resilience audit report — tools, 10 findings, fixes

### Fixed / Исправлено

- **F-05 (SC2029)**: `nasa-send-report-telegram.sh` — Telegram token no longer appears
  in `ps aux` on VPS; passed via ephemeral SSH env file on remote
- **F-06**: `nasa-daily-report-telegram.service` — added `Restart=on-failure` + `RestartSec=60`
- **F-08 (SC2046)**: `scripts/fetch_external_docs.sh:182` — `$(find ...)` replaced with `xargs`
- **Immich healthcheck endpoint**: corrected from deprecated `/api/server-info/ping`
  to `/api/server/ping` (Immich v1.100+)

### Changed / Изменено

- README: complete rewrite to reflect Stage 1 complete state — all services live,
  accurate architecture diagram, updated stages/docs/stack tables
- `docker-compose.nextcloud.yml`, `docker-compose.immich.yml`: `restart: unless-stopped`
  → `restart: always` for all services (applied live via `docker update`)
- Audit report status updated: F-02 → MEDIUM/Mitigated, F-03/F-04/F-06/F-07 → Fixed

### Added / Добавлено (deep audit 2026-06-20)

- `config/.env.example`: `STORAGE_DEVICE` variable for SMART monitoring; `SAMBA_NAS_PASSWORD`
  for Samba secrets; `VPS_HOST` changed from real IP to placeholder `your.vps.ip.here`
- `docker/compose/docker-compose.stage1.yml`: `mem_limit` on all services (protect 4 GB / no-swap Jetson);
  `immich-microservices` moved to `profiles: [microservices]` (off by default); `immich-redis`
  now password-protected; removed incorrect `depends_on: nextcloud` from `llm-gateway`;
  added `REDIS_PASSWORD` env to `immich-server`
- `.github/workflows/validate-compose.yml`: added CI validation for 3 new compose files
  (`docker-compose.samba.yml`, `docker-compose.monitoring.yml`, `docker/vps/docker-compose.yml`)
- `systemd/jetson-nas-mount.service`: replaced `mount -a` (all fstab) with targeted
  `mount ${STORAGE_ROOT}` + added `Before=docker.service`

### Changed / Изменено (deep audit 2026-06-20)

- `CHANGELOG.md`: fixed repo URL in footer links (`Nasa_home` not `nasa-home-cloud`)
- `README.md`: fixed clone URL; Samba marked as implemented (not "planned"); updated
  Stack, Architecture, Stages, Known Limitations tables; added all new compose files to table;
  removed stale `IMMICH_DISABLE_MACHINE_LEARNING` limitation note
- `PROJECT_TREE.txt`: fully regenerated — now reflects all directories added since v0.1.0
  (`systemd/`, `tests/`, `configs/samba/`, `scripts/storage/`, `scripts/network/`,
  `docker/vps/`, `docs/articles/`, `docs/17-20_*.md`, `docs/decisions/ADR-0002..0004`, etc.)
- `scripts/network/setup_vps_tunnel.sh`: removed hardcoded fallback `193.8.215.130`;
  script now exits with error if `VPS_HOST` is not set in `.env`

### Added / Добавлено

- NAS research report (`docs/18_NAS_RESEARCH_REPORT.md`): analysis of 6 open-source NAS projects
  (JetsonHacks bootFromUSB, OMV, NextcloudPi, RetroNAS, NasberryPi, docker-samba)
- Samba SMB layer: `docker/compose/docker-compose.samba.yml` (crazymax/samba, ARM64 native)
  + `configs/samba/config.yml` (YAML config) + `configs/samba/smb.conf` (native reference)
- `systemd/` directory: `jetson-nas-health.service`, `jetson-nas-health.timer` (6h),
  `nasa-tunnel.service` (autossh), `jetson-nas-mount.service`
- `tests/` directory: `test_samba_config.sh`, `test_mount.sh`, `test_healthcheck.sh`
- `scripts/storage/setup_disk.sh` — USB HDD mount setup with UUID/fstab (NasberryPi pattern)
- `scripts/storage/benchmark_io.sh` — sequential I/O benchmark (JetsonHacks reference speeds)
- VPS integration: reverse SSH tunnel architecture (`docs/plans/VPS_INTEGRATION_PLAN.md`)
  - autossh tunnel script for Jetson Nano (`scripts/network/setup_vps_tunnel.sh`)
  - nginx reverse proxy compose for VPS (`docker/vps/docker-compose.yml`)
  - VPS UFW rules configured (SSH, Amnezia ports, NASA tunnel ports 8080/2283/8090)
  - Docker Compose v5.1.4 installed on VPS
- `config/.env.example`: added VPS_HOST, VPS_USER, VPS_SSH_KEY section
- Monitoring stack analysis and documentation (`docs/17_MONITORING_OBSERVABILITY.md`)
- Docker Compose for monitoring stack (`docker/compose/docker-compose.monitoring.yml`): Netdata + Uptime Kuma + Portainer, ARM64-native
- `prompts/CODEX_MONITORING_PROMPT.md` — bilingual agent prompt for monitoring deployment
- ADR-0002 (storage design), ADR-0003 (networking LAN-only), ADR-0004 (Tailscale external access)
- `docs/plans/TAILSCALE_ACCESS_PLAN.md` — step-by-step Tailscale setup on Jetson Nano
- Full operational bash scripts: `backup_databases.sh`, `restic_backup_example.sh`, `docker_health.sh`, `storage_health.sh`, `docker_update_plan.sh`, `network_health.sh` (in `scripts/network/`)
- `CODE_OF_CONDUCT.md` (Contributor Covenant v2.1, bilingual RU/EN)
- Existing-data HDD intake documentation: read-only NTFS check flow before using
  `/mnt/storage` or `scripts/storage/setup_disk.sh`
- `docs/19_NETWORK_INVENTORY.md` — sanitized home LAN/router/Jetson/HDD/VPS
  inventory table with secret values kept in `config/.env`
- `docs/20_AGENT_OPERATING_MODEL.md` — standard subagent roles, safety gates,
  report format, and workflow integration

### Changed / Изменено

- `README.md`: added "Old hardware should live" tagline, AI-Assisted badge, updated Samba stack entry
- `AGENTS.md`: added the mandatory subagent operating model pointer and report
  requirements
- `scripts/diagnostics/storage_health.sh`: added SMART monitoring section (smartctl, USB-SATA bridge handling)
- `docs/articles/habr_draft.md`: rewritten with "human vision + AI implementation" angle
- `README.md` переписан по стандартам GitHub open-source проектов: badges, двуязычные секции, ASCII-диаграмма, таблицы стека и документации, Quick Start / README.md rewritten to GitHub open-source standards
- `AGENTS.md` дополнен разделом сетевых ограничений (Amnezia, nasa-lan, Tailscale)
- `docs/13_MONITORING_RUNBOOK.md` расширен: ссылки на мониторинг-стек, таблица алертов
- `docs/16_GITHUB_PUBLICATION.md` дополнен: GitHub Actions, Issue templates, pre-release checklist
- `docker/compose/docker-compose.stage1.yml`: добавлен `immich-microservices`, `IMMICH_DISABLE_MACHINE_LEARNING`, `container_name` для всех сервисов

---

## [0.1.0] - 2026-06-20

### Added / Добавлено

- Initial project structure: `docs/`, `scripts/`, `services/`, `config/`, `docker/`, `prompts/`
- Bilingual documentation (RU/EN) for all stages (Stage 0–3):
  - `docs/00_OVERVIEW.md` — project overview
  - `docs/01_HARDWARE_AUDIT.md` — hardware audit guide
  - `docs/01A_JETSON_SD_BOOTSTRAP.md` — Jetson Nano microSD bootstrap recipe
  - `docs/03_ARCHITECTURE.md` — architecture overview
  - `docs/04_STORAGE_DESIGN.md` — USB HDD storage design
  - `docs/05_NETWORKING_VPN.md` — networking and VPN setup (wg-nasa, EU VPS)
  - `docs/06_NEXTCLOUD_DESIGN.md` — Nextcloud deployment design
  - `docs/07_IMMICH_DESIGN.md` — Immich deployment design (Jetson-safe mode)
  - `docs/08_LLM_GATEWAY_DEEPSEEK.md` — LLM Gateway and DeepSeek API integration
  - `docs/12_BACKUP_RESTORE.md` — backup and restore workflow
  - `docs/14_TEST_PLAN.md` — test plan for staged rollout
  - `docs/16_GITHUB_PUBLICATION.md` — GitHub publication checklist
- Docker Compose drafts (modern Compose spec, top-level `name:` key):
  - `docker/compose/docker-compose.stage1.yml` — full Stage 1 stack
  - `docker/compose/docker-compose.nextcloud.yml` — Nextcloud + PostgreSQL + Redis
  - `docker/compose/docker-compose.immich.yml` — Immich (ML disabled for Jetson Nano)
  - `docker/compose/docker-compose.llm-gateway.yml` — LLM Gateway FastAPI service
- `services/llm-gateway/` — FastAPI privacy shim for DeepSeek API:
  - personal data redaction (email, phone, tokens, private keys)
  - mock mode when `DEEPSEEK_API_KEY` is not set
  - Stage 1 raw-mode block
- `services/backup-api/` — Stage 2 placeholder for Android backup/restore
- `config/.env.example` — public environment variable template (no real secrets)
- `config/llm-policy.yaml` — LLM privacy policy draft
- Diagnostic scripts:
  - `scripts/diagnostics/hardware_audit.sh` — Jetson Nano hardware audit
  - `scripts/diagnostics/docker_health.sh` — Docker and container health check
  - `scripts/diagnostics/storage_health.sh` — USB HDD and mount point health check
- Backup scripts:
  - `scripts/backup/backup_databases.sh` — PostgreSQL dump skeleton
  - `scripts/backup/restic_backup_example.sh` — restic snapshot workflow example
- Security tooling:
  - `scripts/security/check_no_secrets.sh` — pre-publish secret scanner (scans git-tracked files only)
- Agent and Codex prompts:
  - 8 prompt templates in `prompts/CODEX_*` covering Stage 0–2 tasks
- Architecture decision records:
  - `docs/decisions/ADR-0001-nextcloud-immich-deepseek.md` — selected stack rationale
- Project meta files:
  - `README.md` — bilingual project overview (RU/EN)
  - `CONTRIBUTING.md` — contribution rules and good first issues
  - `SECURITY.md` — security policy and LLM privacy rules
  - `AGENTS.md` — agent/Codex onboarding instructions
  - `PROJECT_CONTEXT.md` — fixed decisions and hardware constraints
  - `LICENSE` — MIT License
- GitHub infrastructure:
  - `.github/ISSUE_TEMPLATE/bug_report.md` — bilingual bug report template
  - `.github/ISSUE_TEMPLATE/feature_request.md` — bilingual feature request template
  - `.github/ISSUE_TEMPLATE/config.yml` — issue template configuration
  - `.github/pull_request_template.md` — bilingual PR checklist
  - `.github/CODEOWNERS` — code ownership declaration
  - `.github/workflows/secrets-check.yml` — CI secret scanner on push/PR
  - `.github/workflows/validate-compose.yml` — CI Docker Compose validation

[Unreleased]: https://github.com/AlexeyBorovskoy/Nasa_home/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/AlexeyBorovskoy/Nasa_home/releases/tag/v0.1.0
