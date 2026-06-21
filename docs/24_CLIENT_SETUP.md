# 24. Подключение устройств / Client Setup

> Как подключить телефон, ноутбук и десктоп к NASA Home Cloud.
> Охватывает Android, Windows и Linux — для каждой платформы и каждого сервиса.

---

## Адреса доступа / Access URLs

| Режим | Где работает | Адрес |
|---|---|---|
| **LAN (домашняя сеть)** | Дома, подключён к роутеру | `192.168.0.50` |
| **Внешний (через VPS)** | Везде: 4G, другая сеть | `193.8.215.130` |

| Сервис | LAN | Внешний (VPS) |
|---|---|---|
| Nextcloud | `http://192.168.0.50:8080` | `http://193.8.215.130:8080` |
| Immich | `http://192.168.0.50:2283` | `http://193.8.215.130:2283` |
| LLM Gateway | `http://192.168.0.50:8090` | `http://193.8.215.130:8090` |
| Samba NAS | `\\192.168.0.50` (SMB) | ❌ только LAN |
| nasa-api / Swagger | `http://192.168.0.50:8099/docs` | ❌ только LAN |
| Netdata | `http://192.168.0.50:19999` | ❌ только LAN |
| Uptime Kuma | `http://192.168.0.50:3001` | ❌ только LAN |
| Portainer | `http://192.168.0.50:9000` | ❌ только LAN |

> **Примечание:** Samba и мониторинг — только LAN. Для безопасного внешнего доступа ко всем сервисам — Tailscale (ADR-0004).

---

## Android

### Nextcloud — файлы, фото, контакты, календарь

**Файлы:**
1. Установить [Nextcloud](https://play.google.com/store/apps/details?id=com.nextcloud.client) из Play Store или F-Droid
2. Открыть приложение → "Войти" → ввести адрес сервера:
   - Дома: `http://192.168.0.50:8080`
   - Везде: `http://193.8.215.130:8080`
3. Логин/пароль Nextcloud admin (или создать отдельного пользователя)
4. Включить автозагрузку фото: Профиль → Автозагрузка → выбрать папки

**Контакты и календарь через DAVx⁵:**
1. Установить [DAVx⁵](https://play.google.com/store/apps/details?id=at.bitfire.davdroid)
2. Добавить аккаунт → "Войти с URL и именем пользователя"
3. URL: `http://192.168.0.50:8080/remote.php/dav/`
4. Логин/пароль — те же, что для Nextcloud
5. DAVx⁵ синхронизирует контакты и календарь с системным аккаунтом Android

### Immich — резервная копия фотографий

1. Установить [Immich](https://play.google.com/store/apps/details?id=app.alextran.immich)
2. Открыть → ввести адрес сервера:
   - Дома: `http://192.168.0.50:2283`
   - Везде: `http://193.8.215.130:2283`
3. Войти с логином/паролем Immich (тот же или отдельный пользователь)
4. Профиль → Настройки резервного копирования → включить
5. Immich будет автоматически загружать новые фото и видео на сервер

> Immich — полноценная замена Google Фото. Поддерживает альбомы, совместный доступ, временну́ю шкалу.

### Samba NAS — доступ к сетевым папкам

Для доступа к общим папкам Samba нужен файловый менеджер с поддержкой SMB:

**Вариант 1 — ES File Explorer:**
1. Установить [ES File Explorer](https://play.google.com/store/apps/details?id=com.estrongs.android.pop)
2. Сеть → LAN → Новый → `192.168.0.50`
3. Войти как guest или с логином Samba

**Вариант 2 — Solid Explorer:**
1. Установить [Solid Explorer](https://play.google.com/store/apps/details?id=pl.solidexplorer2)
2. "+" → Network → SMB/CIFS → Хост: `192.168.0.50`

> Samba работает только в домашней сети (LAN). Вне дома — Tailscale.

---

## Windows

### Nextcloud Desktop — синхронизация файлов

1. Скачать [Nextcloud Desktop](https://nextcloud.com/install/#install-clients) для Windows
2. Установить → "Войти" → сервер:
   - Дома: `http://192.168.0.50:8080`
   - Везде: `http://193.8.215.130:8080`
3. Выбрать папку для синхронизации (например `C:\Users\<имя>\Nextcloud`)
4. Отметить папки для синхронизации → ОК
5. Значок в трее — статус синхронизации

**Дополнительно — монтировать как диск (WebDAV):**
1. Открыть "Этот компьютер" → ПКМ → "Подключить сетевой диск"
2. Папка: `http://192.168.0.50:8080/remote.php/dav/files/<логин>/`
3. Отметить "Подключать при входе в систему"
4. Ввести логин/пароль Nextcloud

### Samba NAS — сетевые папки

Самый простой способ — через Проводник:

1. Открыть Проводник → в адресной строке ввести: `\\192.168.0.50`
2. Windows найдёт Jetson и покажет доступные папки (public, family, exchange)
3. ПКМ на нужной папке → "Подключить сетевой диск" → выбрать букву диска

**Команда через PowerShell:**
```powershell
# Подключить как диск N:
net use N: \\192.168.0.50\public /persistent:yes

# Или с логином:
net use N: \\192.168.0.50\family /user:samba_user password /persistent:yes
```

**Проверка:**
```powershell
net use
# должна показать \\192.168.0.50\public  OK
```

### Immich — веб-интерфейс

Immich на Windows открывается в браузере:
- Дома: `http://192.168.0.50:2283`
- Везде: `http://193.8.215.130:2283`

Для автоматической загрузки фото с Windows: загрузка через веб-интерфейс
(нативного Windows-клиента нет, но веб поддерживает drag-and-drop и выбор папок).

### Outlook / Thunderbird — контакты и календарь (CalDAV/CardDAV)

**Thunderbird:**
1. Аккаунт → Параметры → Синхронизация → CalDAV
2. URL: `http://192.168.0.50:8080/remote.php/dav/calendars/<логин>/personal/`
3. CardDAV (контакты): `http://192.168.0.50:8080/remote.php/dav/addressbooks/<логин>/default/`

### Веб-интерфейсы (LAN)

| Сервис | URL | Назначение |
|---|---|---|
| Nextcloud | `http://192.168.0.50:8080` | Файлы, фото, контакты, календарь |
| Immich | `http://192.168.0.50:2283` | Семейный фотоархив |
| LLM Gateway | `http://192.168.0.50:8090` | Локальный AI-ассистент |
| nasa-api Swagger | `http://192.168.0.50:8099/docs` | API сервера |
| Netdata | `http://192.168.0.50:19999` | Мониторинг в реальном времени |
| Uptime Kuma | `http://192.168.0.50:3001` | Статус сервисов |
| Portainer | `http://192.168.0.50:9000` | Управление Docker |

---

## Linux

### Nextcloud Desktop — синхронизация файлов

**Ubuntu/Debian:**
```bash
# Установить Nextcloud Desktop
sudo apt install nextcloud-desktop

# Или через flatpak:
flatpak install flathub com.nextcloud.desktopclient.nextcloud
```

Запустить → ввести сервер `http://192.168.0.50:8080` → логин/пароль → выбрать папку.

**CLI-синхронизация (nextcloudcmd):**
```bash
# Установить
sudo apt install nextcloud-desktop-cmd

# Синхронизировать папку
nextcloudcmd -u admin -p <пароль> ~/nextcloud http://192.168.0.50:8080
```

### Samba — монтирование через fstab

**Разовое монтирование:**
```bash
sudo apt install cifs-utils
sudo mkdir -p /mnt/nas

# Монтировать public-шару
sudo mount -t cifs //192.168.0.50/public /mnt/nas -o guest,vers=2.0
```

**Постоянное монтирование (fstab):**
```bash
# Создать файл с учётными данными (если есть пароль)
echo "username=samba_user" | sudo tee /etc/samba-credentials
echo "password=<пароль>"   | sudo tee -a /etc/samba-credentials
sudo chmod 600 /etc/samba-credentials

# Добавить в /etc/fstab:
//192.168.0.50/public /mnt/nas cifs credentials=/etc/samba-credentials,vers=2.0,nofail,_netdev 0 0

# Смонтировать
sudo mount -a
df -h /mnt/nas
```

**Через Nautilus (GNOME Files) — без монтирования:**
1. Открыть Файлы → "Другие места" → ввести в адресную строку:
   `smb://192.168.0.50/public`
2. Войти как guest или с логином

### Immich — веб

Открыть в браузере: `http://192.168.0.50:2283`

Для автозагрузки можно использовать CLI-утилиту:
```bash
# Immich CLI (node.js)
npm install -g @immich/cli

immich login http://192.168.0.50:2283 <API-ключ>
immich upload ~/Pictures --recursive
```

API-ключ: Immich → Профиль → API-ключи → Создать.

### CalDAV/CardDAV

**GNOME Online Accounts:**
1. Настройки → Онлайн-аккаунты → "Другой аккаунт"
2. CalDAV / CardDAV
3. URL: `http://192.168.0.50:8080/remote.php/dav/`
4. Логин/пароль Nextcloud

**Thunderbird:**
1. Добавить аккаунт → Calendar → "В сети" → CalDAV
2. URL: `http://192.168.0.50:8080/remote.php/dav/calendars/<логин>/personal/`

---

## Tailscale — удалённый доступ ко всем сервисам

> VPS-тоннель открывает только Nextcloud, Immich и LLM Gateway.
> Для доступа к Samba, Netdata, Portainer и nas-api извне — нужен Tailscale.

Установить на все устройства: [tailscale.com/download](https://tailscale.com/download)

После установки и входа в один аккаунт:
- Android/Windows/Linux видят Jetson по адресу Tailscale (100.x.x.x)
- Все порты доступны, как в LAN
- Работает через CGNAT, мобильный интернет, любую сеть

Инструкция: [docs/plans/TAILSCALE_ACCESS_PLAN.md](plans/TAILSCALE_ACCESS_PLAN.md)

---

## Быстрая проверка подключения

```bash
# Проверить доступность с клиентской машины (замени IP при необходимости)
curl -sf http://192.168.0.50:8080/status.php | python3 -m json.tool  # Nextcloud
curl -sf http://192.168.0.50:2283/api/server/ping                     # Immich
curl -sf http://192.168.0.50:8099/healthcheck                         # nasa-api
ping 192.168.0.50                                                      # базовая связь
```
