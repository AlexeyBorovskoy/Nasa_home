# NASA Home Cloud

Codex-ready blueprint for a private family cloud on low-power home hardware.

The project is designed around **NVIDIA Jetson Nano + USB HDD** and can later be adapted to Raspberry Pi, mini-PCs, or other ARM/SBC devices. It combines self-hosted storage, photo backup, admin automation, and a privacy-controlled LLM gateway.

## What This Project Builds

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

The repository is not a one-command production installer yet. It is an engineering template with documentation, compose files, diagnostics, and agent prompts for safe step-by-step deployment.

## Core Principles

- **Privacy first:** personal photos, videos, contacts, calendars, documents, and backup manifests must not be sent to an external LLM.
- **LAN/VPN only:** Nextcloud, Immich, LLM Gateway, and SSH are not meant to be opened directly to the public internet.
- **Small steps:** every deployment block should be checked before moving to the next one.
- **No real secrets in git:** `.env`, tokens, API keys, private keys, dumps, logs, and personal data are excluded from the repository.
- **No local LLM on Jetson Nano in Stage 1:** Jetson Nano is used as a home server, not as an LLM inference node.

## Planned Stack

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

## Target Hardware

| Component | Recommended value |
|---|---|
| Compute node | NVIDIA Jetson Nano Developer Kit |
| System drive | microSD 64 GB or larger |
| Data drive | USB HDD with external power |
| Network | Ethernet for Jetson, Wi-Fi for clients |
| Router | Gigabit router with static DHCP lease support |
| External access | VPN / mesh VPN only |

Jetson Nano has limited RAM and CPU headroom. Heavy ML photo analysis, large video transcoding jobs, and local LLM inference are intentionally out of scope for Stage 1.

## Repository Layout

```text
config/
  .env.example              Public environment template
  llm-policy.yaml           Stage 1 LLM privacy policy draft

docker/compose/
  docker-compose.stage1.yml Full Stage 1 stack draft
  docker-compose.nextcloud.yml
  docker-compose.immich.yml
  docker-compose.llm-gateway.yml

docs/
  00_OVERVIEW.md
  01_HARDWARE_AUDIT.md
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
  llm-gateway/              FastAPI gateway with redaction and mock mode
  backup-api/               Stage 2 placeholder API for Android backup/restore

scripts/
  diagnostics/              Hardware, Docker, and storage checks
  backup/                   Backup examples and DB dump placeholder
  security/                 Publication checks

prompts/
  CODEX_*                   Agent prompts for staged implementation
```

## Deployment Stages

| Stage | Scope | Status |
|---|---|---|
| 1A | Hardware audit, storage, Samba/SFTP | Designed |
| 1B | Nextcloud | Compose draft |
| 1C | Immich with constrained load | Compose draft |
| 1D | DeepSeek LLM Gateway | FastAPI skeleton exists |
| 1E | Backup/restore | Docs and script drafts |
| 2 | Android backup/restore client | Architecture only |
| 3 | Extended analytics, RAG, provider fallback | Future |

## Quick Start For Agents

1. Read `AGENTS.md`.
2. Read `PROJECT_CONTEXT.md`.
3. Run the hardware audit on the target host:

```bash
./scripts/diagnostics/hardware_audit.sh
```

4. Prepare storage according to `docs/04_STORAGE_DESIGN.md`.
5. Create a local environment file:

```bash
cp config/.env.example config/.env
chmod 600 config/.env
```

6. Replace all placeholder values in `config/.env` locally. Do not commit it.
7. Deploy one block at a time: storage, NAS access, Nextcloud, Immich, LLM Gateway, backups.

## Compose Compatibility Note

The compose files use the modern Compose specification, including the top-level `name:` key. Use Docker Compose v2:

```bash
docker compose version
docker compose -f docker/compose/docker-compose.stage1.yml --env-file config/.env config
```

Older `docker-compose` v1 may reject the files.

## LLM Gateway

`services/llm-gateway` is a small FastAPI service that:

- accepts safe administrative prompts;
- redacts obvious emails, phone numbers, tokens, passwords, and private keys;
- uses mock mode when `DEEPSEEK_API_KEY` is not configured;
- blocks raw mode in Stage 1.

Allowed Stage 1 use cases:

- explaining anonymized Docker errors;
- summarizing service health;
- generating runbooks from non-sensitive diagnostics;
- working with project documentation.

Forbidden Stage 1 use cases:

- analyzing personal photos or videos;
- sending contacts, calendars, documents, database dumps, backup manifests, tokens, or private keys;
- exposing the gateway directly to the internet.

## Security Checklist Before Publishing

Run:

```bash
./scripts/security/check_no_secrets.sh
find . -name '.env' -o -name '*.key' -o -name '*.pem' -o -name '*.p12' -o -name '*.pfx'
```

Review the output manually before pushing. The repository is intended to contain only templates, documentation, and source code.

## Current Limitations

- The project has not yet been validated on the real Jetson host.
- `backup_databases.sh` is still a placeholder.
- Immich machine-learning disable flags need to be wired into compose before a constrained Jetson test.
- `config/llm-policy.yaml` documents the target policy, but not every limit is enforced in code yet.
- `services/backup-api` is a Stage 2 placeholder and should not be used as a production backup service.

## Roadmap

- `v0.1`: public documentation and safe repository bootstrap.
- `v0.2`: hardware audit and storage preparation scripts.
- `v0.3`: validated Nextcloud deployment.
- `v0.4`: validated Immich deployment with Jetson-safe settings.
- `v0.5`: backup and restore workflow.
- `v0.6`: LLM Gateway policy enforcement.
- `v0.7`: Android Stage 2 API draft.
- `v1.0`: verified installation on Jetson Nano and one additional low-power device.

## License

MIT. See `LICENSE`.
