# 13. Monitoring / Runbook

> Подробный анализ инструментов мониторинга и стратегия развёртывания:
> `docs/17_MONITORING_OBSERVABILITY.md`.
>
> Compose-файл мониторинг-стека: `docker/compose/docker-compose.monitoring.yml`.
>
> Промпт агента для развёртывания: `prompts/CODEX_MONITORING_PROMPT.md`.

## 1. Ежедневные проверки

```bash
df -h
free -h
docker compose ps
sudo dmesg | grep -i -E "error|reset|fail|i/o" | tail -n 100
```

## 2. Проверка HDD

```bash
sudo smartctl -a /dev/sda || sudo smartctl -a -d sat /dev/sda
```

## 3. Проверка Docker

```bash
docker compose -f docker/compose/docker-compose.stage1.yml ps
docker stats --no-stream
```

## 4. Если Nextcloud не открывается

1. Проверить сеть:

```bash
ping 192.168.0.50
```

2. Проверить контейнеры:

```bash
docker compose ps
docker compose logs --tail=100 nextcloud
```

3. Проверить диск:

```bash
df -h /mnt/storage
```

4. Проверить БД:

```bash
docker compose logs --tail=100 nextcloud-db
```

## 5. Если Immich тормозит

1. Проверить RAM:

```bash
free -h
docker stats --no-stream
```

2. Отключить ML.
3. Остановить массовый импорт.
4. Проверить PostgreSQL.

## 6. Если HDD отваливается

1. Проверить питание HDD.
2. Проверить кабель.
3. Проверить `dmesg`.
4. Проверить SMART.
5. Не запускать БД до стабилизации.

---

## 7. Мониторинг-стек Stage 1 (Netdata + Uptime Kuma + Portainer)

Мониторинг разворачивается отдельным compose-файлом. Подробный анализ
инструментов и стратегия развёртывания: `docs/17_MONITORING_OBSERVABILITY.md`.

### Запуск мониторинга

```bash
docker compose -f docker/compose/docker-compose.monitoring.yml \
               --env-file config/.env up -d
```

### Проверка статуса мониторинга

```bash
docker compose -f docker/compose/docker-compose.monitoring.yml ps
```

### Веб-интерфейсы

| Инструмент | URL | Назначение |
|---|---|---|
| Netdata | `http://192.168.0.50:19999` | Системный мониторинг, Docker stats, температура |
| Uptime Kuma | `http://192.168.0.50:3001` | HTTP uptime, Telegram-уведомления |
| Portainer | `http://192.168.0.50:9000` | Docker management UI |

### Что смотреть в Netdata

- **System → CPU** — общая загрузка и per-core
- **System → RAM** — используемая память; при > 90% срочно смотреть `docker stats`
- **Disk Space → /mnt/storage** — заполненность: алерт при > 85%
- **Docker → Containers** — состояние всех контейнеров Stage 1
- **Temperature** — тепловые зоны Jetson; алерт при > 85°C

Если Netdata показывает алерт — см. соответствующий раздел ниже (разделы 4–6)
или подробный runbook в `docs/17_MONITORING_OBSERVABILITY.md` (секция «Алерты»).

### Что делать, если Uptime Kuma прислал уведомление

| Уведомление | Действие |
|---|---|
| Nextcloud недоступен | Перейти к разделу 4 настоящего runbook |
| Immich недоступен | Перейти к разделу 5 настоящего runbook |
| LLM Gateway недоступен | `docker logs homecloud_llm_gateway --tail=50` |

### Остановка мониторинга (если мешает или вызывает OOM)

```bash
docker compose -f docker/compose/docker-compose.monitoring.yml \
               --env-file config/.env down
```

Данные Uptime Kuma (история мониторинга) и настройки Portainer сохраняются
в именованных volumes и восстанавливаются при повторном `up -d`.
