# План: Tailscale внешний доступ к Jetson Nano

**Статус:** Запланировано (Stage 2)
**Решение:** ADR-0004
**Дата:** 2026-06-20

---

## Цель

Настроить внешний доступ к Nextcloud/Immich/LLM Gateway через мобильный интернет без нарушения LAN-конфигурации и Amnezia VPN семьи.

## Предварительные условия

- [ ] Stage 1 завершён: Nextcloud работает в LAN.
- [ ] SSH-доступ к Jetson: `ssh admin@192.168.0.50` или USB `ssh admin@fe80::1%<ifIndex>`.
- [ ] Jetson подключён к интернету (eth0 в LAN).
- [ ] Аккаунт на tailscale.com (бесплатный).

## ⚠️ Что НЕ делать

> Не трогать Amnezia-сервер на EU VPS. `wg set` или редактирование конфигов вызывает рестарт контейнера → VPN ~25 клиентов падает. См. ADR-0003.

---

## Этапы

### Шаг 1: Аккаунт Tailscale

Зарегистрироваться на https://tailscale.com (Google/GitHub).

### Шаг 2: Установка на Jetson

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
# → открыть ссылку авторизации в браузере
tailscale ip -4   # запомнить Tailscale IP (100.x.x.x)
sudo systemctl enable tailscaled
```

### Шаг 3: Android

Play Store → "Tailscale" → войти с тем же аккаунтом.

### Шаг 4: Проверка (телефон на мобильных данных)

```
ping 100.x.x.x
http://100.x.x.x:8080   # Nextcloud
http://100.x.x.x:2283   # Immich
```

### Шаг 5: Nextcloud trusted_domains

```bash
# config/.env
NEXTCLOUD_TRUSTED_DOMAINS=192.168.0.50 100.x.x.x

# Применить в запущенном контейнере
docker exec homecloud_nextcloud php occ config:system:set \
    trusted_domains 2 --value="100.x.x.x"
```

---

## Rollback

```bash
sudo tailscale down
sudo apt remove tailscale
```

Amnezia и `nasa-lan` остаются нетронутыми.

---

## Следующий шаг

Задокументировать результат в `docs/05_NETWORKING_VPN.md` §3.4.