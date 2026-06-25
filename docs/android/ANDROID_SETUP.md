# Android Mobile Setup — NASA Home Cloud

Практическое руководство по настройке Xiaomi (MIUI / HyperOS) для синхронизации
с самохостинговыми сервисами: Immich, Nextcloud, CardDAV/CalDAV.

---

## Архитектура доступа

```
Xiaomi (дома)
  └── Wi-Fi → 192.168.0.50 (Jetson LAN, напрямую)

Xiaomi (вне дома)
  └── Amnezia VPN → VPS 193.8.215.130
        └── nginx reverse proxy → SSH tunnel → Jetson 192.168.0.50
```

Оба сценария используют одинаковые URL — приложения умеют работать с двумя серверами
(home/away) или с постоянным VPN-адресом.

**Почему не Tailscale:** Tailscale и Amnezia оба создают VPN-профиль на Android.
Android позволяет активировать только один VPN одновременно → выбираем Amnezia (уже стоит)
+ nginx на VPS как прокси-слой.

---

## Требования (серверная сторона)

| Компонент | Статус |
|---|---|
| Jetson Nano запущен | ✅ |
| Immich работает на :2283 | ✅ |
| Nextcloud работает на :8080 | ✅ |
| Beszel мониторинг | ✅ |
| **nginx на VPS (HTTPS)** | ⏳ нужно установить (`scripts/setup/install_nginx_vps.sh`) |

---

## Шаг 1. Установить nginx на VPS

> Выполняется один раз. Без этого шага удалённый доступ через Amnezia не работает.

```bash
# На Windows (Git Bash):
ssh -i ~/.ssh/borovskoy_new_ed25519 root@193.8.215.130 \
  "bash -s" < scripts/setup/install_nginx_vps.sh
```

После установки сервисы доступны по адресам:

| Сервис | HTTP (уже работает) | HTTPS (после скрипта) |
|---|---|---|
| Nextcloud | `http://193.8.215.130:8080` | `https://193.8.215.130:8443` |
| Immich | `http://193.8.215.130:2283` | `https://193.8.215.130:2443` |
| LLM Gateway | `http://193.8.215.130:8090` | `https://193.8.215.130:9443` |

Самоподписанный сертификат — принять предупреждение один раз в браузере/приложении.

---

## Шаг 2. Immich — синхронизация фото

### Установить приложение

**[Immich](https://play.google.com/store/apps/details?id=app.alextran.immich)** в Google Play
или APK с [github.com/immich-app/immich/releases](https://github.com/immich-app/immich/releases)

### Настройка

1. Открыть Immich → **Войти** → ввести адрес сервера
2. **Дома (Wi-Fi):** `http://192.168.0.50:2283`  
   **Вне дома (Amnezia):** `https://193.8.215.130:2443`
3. Создать пользователя в Immich (или использовать существующего)

### Настройка автозагрузки

Immich → **Профиль** → **Резервное копирование** → ✅ Включить фоновое резервное копирование

Рекомендуемые настройки:
- ✅ Резервное копирование при Wi-Fi (экономия трафика)
- ✅ Исключить скриншоты (Settings → Excluded Albums)
- ✅ Видео тоже копировать
- Начать с **Только дома (Wi-Fi)** → потом включить Amnezia + мобильный интернет

### Важно для Xiaomi MIUI/HyperOS

> Без этих настроек Immich не будет грузить фото в фоне!
> Подробности: [XIAOMI_MIUI_QUIRKS.md](XIAOMI_MIUI_QUIRKS.md)

---

## Шаг 3. Nextcloud — файловое облако

### Установить приложение

**[Nextcloud](https://play.google.com/store/apps/details?id=com.nextcloud.client)** в Google Play

### Настройка

1. Nextcloud → **Войти** → ввести адрес сервера:
   - Дома: `http://192.168.0.50:8080`
   - Вне дома: `https://193.8.215.130:8443`
2. Ввести логин/пароль Nextcloud (admin или персональный аккаунт)
3. Разрешить доступ к файлам

### Автозагрузка файлов (замена Google Drive)

Nextcloud → **⋮** → **Автозагрузка** → выбрать папки:
- `DCIM/Camera` → альтернатива Immich для резервного (необязательно, если Immich есть)
- `Documents` → документы
- `Download` → загрузки

---

## Шаг 4. Контакты и Календарь (DAVx⁵)

DAVx⁵ — мост между стандартными контактами/календарями Android и Nextcloud (CardDAV/CalDAV).

### Установить DAVx⁵

**[DAVx⁵](https://play.google.com/store/apps/details?id=at.bitfire.davdroid)** в Google Play  
(платное) или бесплатно через **[F-Droid](https://f-droid.org/packages/at.bitfire.davdroid/)**

### Настройка

1. DAVx⁵ → **+** → **Войти с URL**
2. **Base URL:**
   - Дома: `http://192.168.0.50:8080/remote.php/dav`
   - Вне дома: `https://193.8.215.130:8443/remote.php/dav`
3. Логин/пароль Nextcloud → **Далее**
4. DAVx⁵ найдёт: адресную книгу (CardDAV) и календари (CalDAV)
5. ✅ Включить синхронизацию нужных коллекций

### Частота синхронизации

DAVx⁵ → Аккаунт → ⚙️ → **Интервал синхронизации**: 15 минут (рекомендуется)

---

## Шаг 5. Настройки Xiaomi для фоновой работы

> Это критически важно — MIUI/HyperOS агрессивно убивает фоновые приложения.

Краткий чеклист:
- ⬜ Immich: снять ограничения батареи + разрешить автозапуск
- ⬜ DAVx⁵: снять ограничения батареи + разрешить автозапуск  
- ⬜ Nextcloud: снять ограничения батареи + разрешить автозапуск
- ⬜ Amnezia VPN: снять ограничения батареи (иначе VPN разрывается)

Подробно: **[XIAOMI_MIUI_QUIRKS.md](XIAOMI_MIUI_QUIRKS.md)**

---

## Сетевые профили в приложениях

Immich и Nextcloud поддерживают **разные адреса** для LAN и WAN:

**Immich** (v1.90+):
- Настройки → Server URL → `http://192.168.0.50:2283`
- Автоматически переключается на VPN-адрес при недоступности LAN (НЕ поддерживается нативно — нужен один постоянный адрес)

**Рекомендация:** использовать постоянный HTTPS-адрес (через nginx/VPS) как основной — работает и дома (через Amnezia), и вне дома. Либо настроить локальный DNS на роутере.

---

## Что НЕ синхронизируется без root

| Данные | Статус |
|---|---|
| SMS / MMS | ❌ без root (Stage 4) |
| Журнал звонков | ❌ без root |
| Wi-Fi пароли | ❌ только системный бекап |
| Данные приложений | ❌ без root |
| Настройки системы | ❌ без root |
| APK (список) | ✅ можно экспортировать список |

---

## Ссылки

- [GOOGLE_MIGRATION.md](GOOGLE_MIGRATION.md) — пошаговая миграция с Google
- [XIAOMI_MIUI_QUIRKS.md](XIAOMI_MIUI_QUIRKS.md) — специфика MIUI
- [install_nginx_vps.sh](../../scripts/setup/install_nginx_vps.sh) — скрипт nginx
- [09_ANDROID_STAGE2_ARCHITECTURE.md](../09_ANDROID_STAGE2_ARCHITECTURE.md) — план кастомного приложения
