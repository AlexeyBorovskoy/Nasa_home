import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app import logging_setup
from app.config import settings
from app.routers import actions, health, logs, system

log = logging.getLogger("nasa_api")

# ---------------------------------------------------------------------------
# OpenAPI tag registry — order = section order in Swagger UI
# ---------------------------------------------------------------------------
OPENAPI_TAGS = [
    {
        "name": "Служебные",
        "description": "Базовый healthcheck и сводный статус сервиса.",
    },
    {
        "name": "Система",
        "description": (
            "Метрики Jetson Nano: CPU load, RAM, диск, температурные зоны. "
            "Статус Docker-контейнеров (`docker ps -a`)."
        ),
    },
    {
        "name": "Логи",
        "description": (
            "Чтение последних записей структурированного JSON-лога "
            "(`/var/log/nasa-monitor/nasa-api.jsonl`). "
            "Поддерживает фильтрацию по уровню и подстроке."
        ),
    },
    {
        "name": "Действия",
        "description": (
            "Управляющие действия: ручная отправка Telegram-отчёта. "
            "Все действия fire-and-forget (HTTP 202)."
        ),
    },
]

OPENAPI_DESCRIPTION = """\
## NASA Home Cloud — Status & Monitoring API

Сервис мониторинга и управления домашним облаком на базе Jetson Nano.

### Что отслеживается

| Ресурс | Источник |
|--------|----------|
| RAM, CPU load, uptime | `/proc/meminfo`, `/proc/loadavg` |
| Диск `/` и `/mnt/storage` | `os.statvfs` |
| Температура (CPU/GPU/PLL) | `/sys/class/thermal/thermal_zone*` |
| Docker-контейнеры | `docker ps -a` |
| HTTP-статус сервисов | Nextcloud :8080, Immich :2283, LLM GW :8090 |

### Логирование

Все события пишутся в два места:
- **stdout** — plain-text (доступен через `docker logs homecloud_nasa_api`)
- **файл** — JSON-lines с ротацией: `/var/log/nasa-monitor/nasa-api.jsonl`

Формат JSON-строки:
```json
{"ts":"2026-06-21T09:00:01Z","level":"INFO","service":"nasa-api",
 "logger":"nasa_api.system","msg":"metrics polled","ram_used_pct":42.1}
```

### Внешний доступ

Сервис доступен через VPS-туннель:
`http://193.8.215.130:8099/docs`
"""


@asynccontextmanager
async def lifespan(_app: FastAPI):
    logging_setup.setup(
        log_level=settings.api_log_level,
        log_file=settings.log_file,
        max_bytes=settings.log_max_bytes,
        backup_count=settings.log_backup_count,
    )
    log.info("nasa-api starting", extra={"fields": {"port": settings.api_port}})
    yield
    log.info("nasa-api stopped")


app = FastAPI(
    lifespan=lifespan,
    title="NASA Home Cloud — Status & Monitoring API",
    version="0.1.0",
    description=OPENAPI_DESCRIPTION,
    openapi_tags=OPENAPI_TAGS,
    contact={
        "name": "NASA Home Cloud",
        "url": "https://github.com/AlexeyBorovskoy/Nasa_home",
    },
    swagger_ui_parameters={
        "defaultModelsExpandDepth": 1,
        "docExpansion": "list",
        "filter": True,
        "displayRequestDuration": True,
        "tryItOutEnabled": True,
    },
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(system.router)
app.include_router(logs.router)
app.include_router(actions.router)
