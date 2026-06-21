"""
/v1/report/now — trigger Telegram report on demand.
"""

import asyncio
import logging

from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse

from app.config import settings

log = logging.getLogger("nasa_api.actions")
router = APIRouter(prefix="/v1", tags=["Действия"])


@router.post(
    "/report/now",
    summary="Отправить Telegram-отчёт немедленно",
    description=(
        "Запускает `nasa-send-report-telegram.sh` в фоне. "
        "Возвращает HTTP 202 сразу; фактическая отправка занимает ~10–15 с. "
        "Результат — в `/v1/logs` (уровень INFO/ERROR, logger `nasa_api.actions`)."
    ),
    status_code=202,
)
async def trigger_report():
    async def _run():
        try:
            proc = await asyncio.create_subprocess_exec(
                settings.report_cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.STDOUT,
            )
            stdout, _ = await asyncio.wait_for(proc.communicate(), timeout=60)
            output = stdout.decode().strip()
            if proc.returncode == 0:
                log.info(
                    "Telegram report sent on demand",
                    extra={"fields": {"output": output[-200:]}},
                )
            else:
                log.error(
                    "Telegram report failed (rc=%d)", proc.returncode,
                    extra={"fields": {"output": output[-500:]}},
                )
        except asyncio.TimeoutError:
            log.error("Telegram report timed out after 60s")
        except Exception as exc:
            log.error("Telegram report error: %s", exc)

    asyncio.get_event_loop().create_task(_run())
    return JSONResponse(status_code=202, content={"accepted": True, "message": "Report dispatched"})
