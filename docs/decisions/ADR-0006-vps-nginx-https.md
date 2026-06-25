# ADR-0006: HTTPS для VPS nginx — самоподписанный сертификат

**Дата:** 2026-06-25  
**Статус:** Accepted  
**Автор:** AlexeyBorovskoy  

---

## Контекст

До 2026-06-25 VPS nginx (`nasa_nginx` Docker контейнер) обслуживал Nextcloud и Immich
только по HTTP на портах 8080 и 2283. Android-приложениям (Immich, Nextcloud, DAVx⁵)
необходимо HTTPS для стабильной работы вне домашней сети (через Amnezia VPN → VPS).

**Ограничения:**
- Порт 443 занят Amnezia xray (Docker контейнер) — нельзя освободить
- Нет доменного имени → Let's Encrypt недоступен
- VPS используется совместно с Amnezia VPN (~25 клиентов), нельзя трогать существующую конфигурацию

**Варианты:**
1. Tailscale — создаёт конфликт VPN-профиля с Amnezia на Android (Android позволяет один активный VPN)
2. Let's Encrypt на кастомном домене — требует доменное имя и публичный порт 80/443
3. **Самоподписанный сертификат на alt-портах** — работает без домена, без конфликта с Amnezia

---

## Решение

Добавить HTTPS к существующему `nasa_nginx` Docker контейнеру через дополнительные server blocks
на нестандартных портах:

| Сервис | HTTP (было) | HTTPS (добавлено) |
|---|---|---|
| Nextcloud | :8080 | :8443 |
| Immich | :2283 | :2443 |
| LLM Gateway | :8090 | :9443 |

**Сертификат:** OpenSSL self-signed, RSA 2048, SAN с VPS IP, срок 10 лет.  
**Файлы:** `/opt/nasa/nginx/ssl/nasa.crt` + `nasa.key` (chmod 600)  
**Скрипт:** `scripts/setup/install_nginx_vps.sh` — идемпотентный, безопасный.

**Nextcloud trusted proxy** настроен через `occ`:
```bash
docker exec -u www-data homecloud_nextcloud php occ config:system:set trusted_proxies 0 --value='127.0.0.1'
docker exec -u www-data homecloud_nextcloud php occ config:system:set trusted_proxies 1 --value='193.8.215.130'
docker exec -u www-data homecloud_nextcloud php occ config:system:set overwriteprotocol --value='https'
docker exec -u www-data homecloud_nextcloud php occ config:system:set forwarded_for_headers 0 --value='HTTP_X_FORWARDED_FOR'
```

---

## Последствия

**Положительные:**
- Android-приложения (Immich, Nextcloud, DAVx⁵) работают вне дома через Amnezia VPN
- HTTP-эндпоинты сохранены (обратная совместимость)
- Нет влияния на Amnezia VPN контейнеры

**Отрицательные:**
- Самоподписанный сертификат → предупреждение в браузере/приложении при первом подключении
- Нет автоматической ротации сертификата (10 лет — ручная замена)
- Нет HSTS (требует доверенного сертификата)

**Нейтральные:**
- DAVx⁵ поддерживает `Accept untrusted certificate` — 1 раз принять в настройках

---

## Будущее

Когда появится доменное имя:
1. Настроить Let's Encrypt через certbot
2. Обновить nginx конфиги на порт 443
3. Добавить HSTS
4. Удалить самоподписанный сертификат

Инструмент: `certbot --nginx -d subdomain.example.com`
