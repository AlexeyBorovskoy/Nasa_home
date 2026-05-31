# Backup API (Stage 2 placeholder)

Минимальный FastAPI-скелет API для будущего Android-клиента семейного облака.

> **Stage 1: НЕ разворачивать на боевом Jetson.** Сервис работает только в
> mock-режиме (`BACKUP_API_ENABLED=0`) и предназначен для:
> - стабилизации API-контракта до Stage 2;
> - локального запуска и unit-тестов;
> - демо/презентаций.
>
> Stage 2 добавит реальную работу с диском, БД и authn — после отдельного RFC.

## Эндпоинты

| Method | Path | Назначение |
|---|---|---|
| GET  | `/health` | Состояние и режим (real/mock) |
| POST | `/api/v1/devices/register` | Регистрация устройства, возвращает `device_id` |
| POST | `/api/v1/backups/create` | Создать бэкап, возвращает `backup_id` + upload URL |
| POST | `/api/v1/backups/upload?backup_id=…` | Загрузка файла (multipart) |
| GET  | `/api/v1/backups/list?device_id=…` | Список бэкапов |
| POST | `/api/v1/restore/plan` | План восстановления |

Все эндпоинты, кроме `/health`, требуют `Authorization: Bearer <BACKUP_API_TOKEN>`
(в mock-режиме токен не проверяется).

## Запуск локально (для разработки)

```bash
cd services/backup-api
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# Mock-режим (по умолчанию)
uvicorn app.main:app --host 127.0.0.1 --port 8095

# Реальный режим (только для Stage 2)
export BACKUP_API_ENABLED=1
export BACKUP_API_TOKEN="$(openssl rand -hex 32)"
export BACKUP_API_STORAGE_ROOT=/tmp/backups
uvicorn app.main:app --host 127.0.0.1 --port 8095
```

## Безопасность

- Не принимать запросы из публичного интернета — только через VPN.
- Не логировать содержимое загружаемых файлов или Bearer-токен.
- Не отправлять во внешние LLM содержимое бэкапов (см. `config/llm-policy.yaml`).
