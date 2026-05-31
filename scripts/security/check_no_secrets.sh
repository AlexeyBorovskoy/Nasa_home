#!/usr/bin/env bash
set -euo pipefail

SECRET_ASSIGNMENT_PATTERN='[A-Z0-9_]*(API[_-]?KEY|SECRET|TOKEN|PASSWORD|BEARER)[A-Z0-9_]*[[:space:]]*[:=][[:space:]]*['"'"'"]?[A-Za-z0-9_./+=:@-]{16,}'
PRIVATE_KEY_PATTERN='-----BEGIN [A-Z ]*PRIVATE KEY-----'
PLACEHOLDER_PATTERN='(change_me|replace_me|example|mock|REDACTED|ВАШ_)'

matches="$(
  grep -RInE "$SECRET_ASSIGNMENT_PATTERN|$PRIVATE_KEY_PATTERN" . \
  --exclude-dir=.git \
  --exclude-dir=runtime \
  --exclude-dir=__pycache__ \
  --exclude='*.zip' \
  --exclude='.env.example' \
  --exclude='.gitignore' \
  --exclude='README.md' \
  --exclude='AGENTS.md' \
  --exclude='PROJECT_CONTEXT.md' \
  --exclude='AUDIT_*.md' \
  --exclude='*.md' \
  --exclude='check_no_secrets.sh' || true
)"

matches="$(printf '%s\n' "$matches" | grep -Ev "$PLACEHOLDER_PATTERN" || true)"

if [ -n "$matches" ]; then
  printf '%s\n' "$matches"
  echo "Potential secret-like strings found. Review before publishing." >&2
  exit 1
fi

echo "No obvious secrets found outside allowed files."
