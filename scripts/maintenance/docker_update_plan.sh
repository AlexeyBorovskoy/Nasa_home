#!/usr/bin/env bash
set -euo pipefail
cat <<'EOF'
Manual update plan:
1. Create DB dumps.
2. Create restic snapshot.
3. docker compose pull
4. docker compose up -d
5. Check health endpoints.
6. Rollback if failed.
EOF
