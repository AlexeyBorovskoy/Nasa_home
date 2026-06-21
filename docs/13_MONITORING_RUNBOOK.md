# 13. Monitoring / Runbook

> Состояние на 2026-06-21: **мониторинг-стек развёрнут и работает**.
>
> Подробный анализ инструментов: `docs/17_MONITORING_OBSERVABILITY.md`.  
> Логирование и API: `docs/21_LOGGING_API.md`.  
> Аудит надёжности: `docs/22_AUDIT_RESILIENCE.md`.

---

## 1. Быстрая проверка состояния кластера

```bash
# Все контейнеры с healthcheck-статусом:
docker ps --format "{{.Names}}\t{{.Status}}"

# goss — 34 теста (порты, сервисы, файлы, HTTP):
goss -g tests/goss/goss.yaml validate --format tap

# API-статус через nasa-api:
curl -sf http://localhost:8099/v1/containers | python3 -m json.tool
```

## 2. Ежедневные проверки

```bash
df -h /mnt/storage          # место на диске данных
free -h                     # RAM (предупреждение < 300 MB)
docker ps --format "{{.Names}}\t{{.Status}}"  # healthcheck-статусы
sudo dmesg | grep -i -E "error|reset|fail|i/o" | tail -20
```

## 3. Проверка HDD

```bash
sudo smartctl -a /dev/sda || sudo smartctl -a -d sat /dev/sda
```

## 4. Веб-интерфейсы мониторинга

| Инструмент | URL | Назначение |
|---|---|---|
| nasa-api Swagger | `http://192.168.0.50:8099/docs` | Метрики, логи, контейнеры, report/now |
| Netdata | `http://192.168.0.50:19999` | CPU, RAM, Disk, Docker, темп Jetson |
| Uptime Kuma | `http://192.168.0.50:3001` | HTTP uptime, Telegram-уведомления |
| Portainer | `http://192.168.0.50:9000` | Docker management UI |

## 5. Управление сервисами

```bash
# Запуск стека (если контейнер упал и не поднялся сам):
cd ~/nasa
docker compose -f docker/compose/docker-compose.nextcloud.yml  --env-file config/.env up -d
docker compose -f docker/compose/docker-compose.immich.yml     --env-file config/.env up -d
docker compose -f docker/compose/docker-compose.llm-gateway.yml --env-file config/.env up -d
docker compose -f docker/compose/docker-compose.monitoring.yml  --env-file config/.env up -d
docker compose -f docker/compose/docker-compose.nasa-api.yml    --env-file config/.env up -d

# Остановить один стек:
docker compose -f docker/compose/docker-compose.monitoring.yml --env-file config/.env down
```

## 6. Если Nextcloud не открывается

1. Проверить healthcheck-статус:

```bash
docker inspect homecloud_nextcloud --format "{{.State.Health.Status}}"
```

2. Проверить зависимости (DB + Redis должны быть `healthy`):

```bash
docker ps --format "{{.Names}}\t{{.Status}}" | grep -E "nextcloud"
```

3. Проверить логи:

```bash
docker logs homecloud_nextcloud --tail=50
docker logs homecloud_nextcloud_db --tail=20
```

4. Проверить диск:

```bash
df -h /mnt/storage
```

## 7. Если Immich тормозит

1. Проверить RAM и CPU:

```bash
docker stats --no-stream | grep immich
```

2. Убедиться, что ML отключён (`IMMICH_DISABLE_MACHINE_LEARNING=true` в compose).
3. Остановить массовый импорт фото.
4. Проверить PostgreSQL:

```bash
docker logs homecloud_immich_db --tail=30
```

## 8. Если HDD отваливается

1. Проверить питание и кабель.
2. Проверить dmesg:

```bash
sudo dmesg | grep -E "sda|usb" | tail -20
```

3. Проверить SMART:

```bash
sudo smartctl -a /dev/sda
```

4. Не запускать БД до стабилизации — данные в `/mnt/storage`.

## 9. Telegram ежедневный отчёт

```bash
# Статус таймера:
systemctl status nasa-daily-report-telegram.timer

# Отправить немедленно (тест):
sudo /usr/local/sbin/nasa-send-report-telegram.sh

# Логи последней отправки:
cat /var/log/nasa-monitor/last-report.txt
cat /var/log/nasa-monitor/last-telegram-send.json

# Следующий запуск:
systemctl list-timers nasa-daily-report-telegram.timer
```

## 10. Что смотреть в Netdata

- **System → CPU** — при 19%+ постоянно: возможно утечка или ML в Immich
- **System → RAM** — при < 300 MB свободно: смотреть `docker stats --no-stream`
- **Disk Space → /mnt/storage** — алерт при > 80%
- **Docker → Containers** — состояние всех контейнеров
- **Temperature** — тепловые зоны Jetson; алерт при > 85°C

## 11. Что делать при уведомлении Uptime Kuma

| Уведомление | Действие |
|---|---|
| Nextcloud недоступен | Раздел 6 настоящего runbook |
| Immich недоступен | Раздел 7 настоящего runbook |
| LLM Gateway недоступен | `docker logs homecloud_llm_gateway --tail=50` |
| nasa-api недоступен | `docker logs homecloud_nasa_api --tail=50` |

## 12. nasa-api — полезные запросы

```bash
# Метрики системы (RAM, CPU load, диски, температура):
curl -sf http://localhost:8099/v1/metrics | python3 -m json.tool

# Статус всех контейнеров:
curl -sf http://localhost:8099/v1/containers | python3 -m json.tool

# Последние 50 строк лога (с фильтром уровня):
curl -sf "http://localhost:8099/v1/logs?limit=50&level=ERROR" | python3 -m json.tool

# Отправить Telegram-отчёт вручную через API:
curl -X POST http://localhost:8099/v1/report/now
```
