# 13. Monitoring / Runbook

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
