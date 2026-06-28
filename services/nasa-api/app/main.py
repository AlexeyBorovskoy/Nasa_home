import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app import logging_setup
from app.config import settings
from app.routers import actions, auth, health, logs, storage, system

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
        "name": "Авторизация",
        "description": (
            "JWT-авторизация через Nextcloud OCS. "
            "`POST /api/auth/login` → Bearer token → используй в Authorize (🔒) выше. "
            "Логин/пароль — те же что в Nextcloud."
        ),
    },
    {
        "name": "Система",
        "description": (
            "Метрики Jetson Nano: CPU load, RAM, диск, температурные зоны. "
            "Статус Docker-контейнеров (`docker ps -a`)."
        ),
    },
    {
        "name": "Хранилище",
        "description": (
            "Статус SSD `/mnt/storage`: смонтирован ли, использование, "
            "наличие и возраст резервных копий БД. **Требует JWT.**"
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

### Авторизация

Часть эндпоинтов защищена JWT. Порядок:
1. `POST /api/auth/login` — введи Nextcloud-логин и пароль → получи `access_token`
2. Нажми кнопку **Authorize 🔒** вверху страницы → вставь токен
3. Защищённые эндпоинты (🔒) станут доступны

### Что отслеживается

| Ресурс | Источник | Auth |
|--------|----------|------|
| RAM, CPU load, uptime | `/proc/meminfo`, `/proc/loadavg` | нет |
| Диск `/` и `/mnt/storage` | `os.statvfs` | нет |
| Температура (CPU/GPU/PLL) | `/sys/class/thermal/thermal_zone*` | нет |
| Docker-контейнеры | `docker ps -a` | нет |
| HTTP-статус сервисов | Nextcloud :8080, Immich :2283, LLM GW :8090 | нет |
| SSD статус + backup-дампы | `/mnt/storage` | **JWT** |

### Логирование

Все события пишутся в два места:
- **stdout** — plain-text (доступен через `docker logs homecloud_nasa_api`)
- **файл** — JSON-lines с ротацией: `/var/log/nasa-monitor/nasa-api.jsonl`

### Внешний доступ

Сервис доступен через VPS-туннель: `http://193.8.215.130:8099/docs`
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
    version="0.2.0",
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
        "persistAuthorization": True,
    },
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(auth.router)
app.include_router(system.router)
app.include_router(storage.router)
app.include_router(logs.router)
app.include_router(actions.router)
