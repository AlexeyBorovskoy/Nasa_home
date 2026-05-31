# LLM Gateway

## Русская версия

Минимальный FastAPI-сервис для безопасного доступа к DeepSeek API.

В Stage 1 шлюз нужен, чтобы все обращения к внешнему LLM проходили через один privacy-контур: redaction, запрет raw-mode и mock-режим без API-ключа.

### Возможности Stage 1

- `/health` — состояние сервиса;
- `/v1/redact` — тест redaction;
- `/v1/chat` — безопасный chat-запрос;
- `/v1/diagnostics/explain` — объяснение обезличенной диагностики.

### Ограничения

Сервис не должен получать:

- фото;
- видео;
- контакты;
- календарь;
- приватные документы;
- backup-архивы;
- секреты, токены и приватные ключи.

## English Version

Minimal FastAPI service for safe access to DeepSeek API.

In Stage 1, the gateway exists so every external LLM request goes through one privacy boundary: redaction, raw-mode blocking, and mock mode without an API key.

### Stage 1 Capabilities

- `/health` — service status;
- `/v1/redact` — test redaction;
- `/v1/chat` — safe chat request;
- `/v1/diagnostics/explain` — explain anonymized diagnostics.

### Restrictions

The service must not receive photos, videos, contacts, calendars, private documents, backup archives, secrets, tokens, or private keys.
