# ADR-0005: VPS + autossh reverse SSH tunnel для внешнего доступа

## Статус

**Реализовано** (2026-06-21).

## Контекст

Jetson Nano находится за домашним провайдером с CGNAT (публичный IP не назначается
домашнему роутеру — трафик проходит через провайдерский NAT). Прямой port
forwarding невозможен. Amnezia VPN на VPS не трогать (обслуживает ~25 клиентов).

Требования:
- Доступ к Nextcloud / Immich / LLM Gateway снаружи (мобильный интернет, командировки).
- CGNAT-proof.
- Независимость от Amnezia-контейнеров.
- Автоматический старт при подключении Jetson к LAN-роутеру.
- Управление Jetson по SSH с VPS без отдельного канала.

## Рассмотренные варианты

| Вариант | CGNAT | Независим от Amnezia | Сложность | Решение |
|---|---|---|---|---|
| WireGuard через тот же VPS | ✗ (ядро L4T 4.9 = DKMS) | да | высокая | ❌ откачено ADR-0003 |
| Tailscale | ✓ DERP-relay | да | низкая | ❌ третья сторона, данные через DERP |
| ngrok / cloudflared | ✓ | да | очень низкая | ❌ трафик через чужой сервер |
| **Reverse SSH + autossh** | ✓ | да | средняя | ✅ **выбрано** |

## Решение

Jetson инициирует исходящее SSH-соединение к VPS (`root@193.8.215.130`).
CGNAT не блокирует исходящие соединения. VPS sshd принимает и удерживает
reverse-порты на `127.0.0.1`. nginx на VPS (в `network_mode: host`) проксирует
публичные запросы на эти localhost-порты.

```
Internet → VPS:8080 → nginx → 127.0.0.1:18080 → SSH tunnel → Jetson:8080
Internet → VPS:2283 → nginx → 127.0.0.1:12283 → SSH tunnel → Jetson:2283
Internet → VPS:8090 → nginx → 127.0.0.1:18090 → SSH tunnel → Jetson:8090
VPS → ssh -p 10022 admin@127.0.0.1  → SSH tunnel → Jetson:22
```

## Реализация

**На Jetson:**

```bash
# SSH-ключ
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519

# /opt/nasa/config/.env
VPS_HOST=193.8.215.130
VPS_USER=root
VPS_SSH_KEY=/home/admin/.ssh/id_ed25519

# systemd
sudo cp systemd/nasa-tunnel.service /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable --now nasa-tunnel.service
```

**nasa-tunnel.service:**
```ini
[Service]
ExecStart=/usr/bin/autossh -N \
    -R 18080:localhost:8080 \
    -R 12283:localhost:2283 \
    -R 18090:localhost:8090 \
    -R 10022:localhost:22 \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -o ExitOnForwardFailure=yes \
    -o StrictHostKeyChecking=accept-new \
    -i "${VPS_SSH_KEY}" \
    "${VPS_USER}@${VPS_HOST}"
Restart=always
RestartSec=10
```

**На VPS — nginx (`/opt/nasa/docker-compose.yml`):**

```yaml
services:
  nginx:
    image: nginx:alpine
    network_mode: host   # обязательно! иначе 127.0.0.1:18080 = loopback контейнера
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
```

**Важная деталь:** nginx должен работать в `network_mode: host`. В bridge-режиме
`127.0.0.1` внутри контейнера — это loopback самого контейнера, а не хоста, где
слушает SSH тоннель. Именно это стало основной ошибкой при первоначальной настройке.

## Последствия

- VPS публично открыт на портах 8080/2283/8090 (HTTP, без TLS пока).
- При изменении IP VPS: обновить `VPS_HOST` в `/opt/nasa/config/.env` на Jetson,
  перезапустить `nasa-tunnel.service`.
- Amnezia VPN не затронут (работает на своих портах 36571/443/37238/40568).
- Управление Jetson из любой точки мира: `ssh -p 10022 admin@127.0.0.1` с VPS.
