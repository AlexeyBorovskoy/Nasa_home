#!/usr/bin/env bash
set -euo pipefail
docker compose ps || true
docker stats --no-stream || true
