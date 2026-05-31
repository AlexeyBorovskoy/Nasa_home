# LLM Gateway

Minimal FastAPI service for safe access to DeepSeek API.

Stage 1 capabilities:

- `/health` — service status;
- `/v1/redact` — test redaction;
- `/v1/chat` — safe chat request;
- `/v1/diagnostics/explain` — explain anonymized diagnostics.

The service must not receive photos, videos, contacts, calendars, private documents or backup archives.
