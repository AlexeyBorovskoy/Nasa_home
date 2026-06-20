# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added / Добавлено

- Monitoring stack analysis and documentation (`docs/17_MONITORING_OBSERVABILITY.md`)
- Docker Compose for monitoring stack (`docker/compose/docker-compose.monitoring.yml`): Netdata + Uptime Kuma + Portainer, ARM64-native
- `prompts/CODEX_MONITORING_PROMPT.md` — bilingual agent prompt for monitoring deployment
- ADR-0002 (storage design), ADR-0003 (networking LAN-only), ADR-0004 (Tailscale external access)
- `docs/plans/TAILSCALE_ACCESS_PLAN.md` — step-by-step Tailscale setup on Jetson Nano
- Full operational bash scripts: `backup_databases.sh`, `restic_backup_example.sh`, `docker_health.sh`, `storage_health.sh`, `docker_update_plan.sh`, `network_health.sh` (in `scripts/network/`)
- `CODE_OF_CONDUCT.md` (Contributor Covenant v2.1, bilingual RU/EN)

### Changed / Изменено

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

[Unreleased]: https://github.com/AlexeyBorovskoy/nasa-home-cloud/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/AlexeyBorovskoy/nasa-home-cloud/releases/tag/v0.1.0
