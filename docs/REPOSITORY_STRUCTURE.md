# Repository Structure — NASA Home Cloud

> Where things live and why. Follow this guide when adding new files.

## Top-level layout

```
Nasa_home/
├── README.md                  — project entry point
├── CHANGELOG.md               — version history
├── CLAUDE.md                  — Claude Code agent instructions
├── AGENTS.md                  — multi-agent operating model
├── CONTRIBUTING.md            — contribution guide
├── SECURITY.md                — security policy
├── CODE_OF_CONDUCT.md         — community norms
├── LICENSE                    — MIT
├── .gitignore / .gitattributes / .editorconfig
├── config/                    — service config templates (no secrets)
├── docker/                    — Docker Compose files
├── scripts/                   — operational scripts
├── systemd/                   — systemd units and overrides
├── services/                  — custom microservice source code
├── tests/                     — automated test scripts
├── docs/                      — all documentation
├── assets/                    — images, diagrams, screenshots
├── artifacts/                 — generated reports, audit outputs
├── archive/                   — deprecated but preserved files
└── .github/                   — CI/CD workflows, issue templates
```

## Where to put new files

| Type of file | Location |
|---|---|
| New feature documentation | `docs/NN_TOPIC.md` |
| Architecture decisions | `docs/decisions/ADR-NNN-title.md` |
| Hardware notes | `docs/hardware/` |
| Android docs | `docs/android/` |
| Agent prompts (Codex/Claude/ChatGPT) | `docs/prompts/` |
| Article drafts (Habr, Hackaday) | `docs/articles/` |
| Quality / test documentation | `docs/quality/` |
| Test results / baseline reports | `docs/quality/results/` |
| External reference links | `docs/references/` |
| Test scripts | `tests/<category>/` |
| Operational scripts | `scripts/<category>/` |
| Service configs (templates only) | `config/<service>/` |
| Docker Compose files | `docker/compose/` |
| VPS-specific compose | `docker/vps/` |
| Hardware photos | `assets/photos/` |
| Architecture diagrams | `assets/diagrams/` |
| UI screenshots | `assets/screenshots/` |
| Audit reports, generated JSON | `artifacts/reports/` |
| Old/superseded files | `archive/legacy/` |
| Old documentation versions | `docs/archive/` (create if needed) |

## Key rules

1. **No secrets in git** — use `config/.env.example` with placeholders; real `.env` is gitignored.
2. **No moving `docker/`, `systemd/`, `scripts/`** — many references in deploy scripts and systemd units.
3. **Agent prompts** go in `docs/prompts/`, not in root or separate `prompts/` dir.
4. **Audit reports** go in `artifacts/reports/` (machine output) or `docs/quality/results/` (human-readable baselines).
5. **Old files** go to `archive/legacy/` via `git mv`, never deleted.
6. **VPN configs** (`wg-*.conf`, `wg-*.png`) are gitignored — contain private keys.
7. **Reference HTML docs cache** (`docs/references/external_docs/`) is gitignored — too large.

## Docker Compose commands

```bash
# Stage 1 (base infra)
docker compose -f docker/compose/docker-compose.stage1.yml --env-file config/.env up -d

# Nextcloud
docker compose -f docker/compose/docker-compose.nextcloud.yml --env-file config/.env up -d

# Immich
docker compose -f docker/compose/docker-compose.immich.yml --env-file config/.env up -d

# Monitoring
docker compose -f docker/compose/docker-compose.monitoring.yml --env-file config/.env up -d

# VPS (run from VPS)
docker compose -f docker/vps/docker-compose.yml --env-file config/.env up -d
```
