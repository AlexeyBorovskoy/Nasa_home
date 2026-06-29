# Домашнее облако на Jetson Nano: задумал я, реализовал Claude Code

> **Платформы:** [Habr.com](https://habr.com)  
> **Хабы:** Системное администрирование · Open Source · Искусственный интеллект · Self-hosted  
> **Теги:** `selfhosted` `nextcloud` `immich` `jetson-nano` `docker` `homelab` `claude-code` `ai-assisted-dev`  
> **Статус проекта (июнь 2026):** Stage 1+2 полностью работает · v1.4.0 · NASA API v0.6.0 · семья подключена  
> **Репозиторий:** [github.com/AlexeyBorovskoy/Nasa_home](https://github.com/AlexeyBorovskoy/Nasa_home)

---

Когда Google Photos урезал бесплатное место, я решил поднять своё облако. Идея была простая: Jetson Nano, который год пылится на полке, + внешний HDD + Docker. Заменить Google Photos, Google Drive, и добавить локальный ИИ-ассистент.

Проблема: я занят, у меня нет времени разбираться в Immich, Nextcloud, Docker Compose, WireGuard и всём остальном с нуля. Тогда я попробовал доверить реализацию **Claude Code** — агентной CLI от Anthropic. И вот что получилось.

<cut>

## Угол статьи: не «что я построил», а «как мы строили вместе»

Это не инструкция «как поднять Nextcloud». Таких на Хабре достаточно. Это рефлексия о том, как **AI-assisted разработка меняет подход к домашним проектам**: ты описываешь что хочешь, ИИ строит, ты решаешь ключевые вещи.

Спойлер: я потратил больше времени на формулировку требований, чем на написание кода.

---

## Железо и исходная точка

- **NVIDIA Jetson Nano Developer Kit** — лежал с 2021 года, куплен для ML-экспериментов
- **microSD 32 GB** — системный диск
- **Внешний USB HDD** (старый, 2 TB) — всё пользовательское хранилище
- **VPS в Вене** — уже был для семейного VPN (Amnezia)
- **Роутер** — Jetson получил статический IP `192.168.0.50`

Ключевое ограничение Jetson Nano: **нет swap, 4 GB RAM**. Это навязывает жёсткий выбор компонентов.

---

## Как выглядел процесс с Claude Code

Я не давал длинные технические задания. Я описывал **намерение**, а агент строил реализацию.

**Промпт 1 — структура проекта:**

```
Приведи проект в порядок. Создай полный проект из данного,
напиши все необходимые подпапки и т.п.
Ориентируйся на использование субагентов
```

Claude Code запустил 4 параллельных субагента:
- Агент A — скрипты диагностики и бэкапа
- Агент B — Docker Compose файлы (8 сервисов)
- Агент C — GitHub-инфраструктура (`.github/`, CI/CD)
- Агент D — ADR-документы (Architecture Decision Records)

Я только отвечал на уточняющие вопросы.

**Промпт 2 — мониторинг:**

```
Я хочу попробовать специальные инструменты по контролю типа zabbix
или иных подобных решений. Проанализируй какие можно использовать.
```

Агент проанализировал 9 инструментов и объяснил, почему **Zabbix не подходит** (нужна 3-я PostgreSQL, 500+ MB RAM → OOM на Jetson без swap). Предложил Netdata + Uptime Kuma + Portainer (~220 MB суммарно). Аргументы были технически корректны.

**Промпт 3 — VPS:**

```
У меня есть внешний VPS 193.8.215.130 его можно использовать.
Ты можешь подключиться и проверить данный сервер.
```

Агент подключился через SSH, обнаружил Amnezia VPN (4 контейнера — семейный VPN ~25 клиентов), **не тронул их**, установил Docker Compose, настроен UFW, создал nginx reverse-tunnel конфигурацию и задокументировал всё — включая то, что Telegram-бот здоровья сервера на VPS продолжает работать.

---

## Момент, когда всё чуть не сломалось

Я сначала хотел изменить WireGuard-конфиг VPS через SSH. Агент предупредил — я не послушал и в другой раз уронил VPN у всей семьи на 40 минут.

Теперь это жёсткое правило в `AGENTS.md`:

```
Никогда не трогать Amnezia-сервер через SSH или wg set.
Только через десктоп-приложение Amnezia.
```

Агент теперь это знает. И напоминает при каждой попытке.

---

## Что выяснилось про Jetson Nano + NAS (аналитика)

Параллельно с разработкой был проведён анализ open-source NAS-проектов для SBC. Вывод: **не брать тяжёлый NAS-дистрибутив**, а собрать гибрид:

| Проект | Что взять |
|--------|-----------|
| JetsonHacks bootFromUSB | Загрузка с USB по UUID/PARTUUID (надёжнее microSD) |
| NasberryPi | Паттерн preflight-проверок и repair-flow |
| crazy-max/docker-samba | ARM64 нативный образ, YAML-конфиг, только SMB2+ |
| OMV / NextcloudPi | SMART + backup-дисциплина (идеология, не стек) |

OpenMediaVault для Jetson Nano — **избыточен**. Он захватывает систему целиком и несовместим с нашим Docker-стеком.

---

## Архитектура итоговой системы

```
Android / Windows / macOS (LAN)
    ├─ Nextcloud App → :8080
    ├─ Immich App → :2283
    ├─ SMB \\jetson-nasa\public → :445
    └─ SSH / SFTP

             Jetson Nano 192.168.0.50
         ┌─────────────────────────────┐
         │ homecloud_nextcloud   :8080 │
         │   + Talk «Семья» (5 чел)   │
         │ homecloud_immich      :2283 │
         │ homecloud_llm_gw      :8090 │
         │ homecloud_nasa_api    :8099 │  ← v0.6.0: Talk/Users/Photos API
         │ homecloud_samba        :445 │
         │ homecloud_*_db (postgres)   │
         │ Netdata + Uptime Kuma       │
         └────────────┬────────────────┘
                      │ USB 3.0 SuperSpeed
              /mnt/storage (JMS583 SSD, 229 GB, 250 MB/s)

Внешний доступ (CGNAT → reverse SSH tunnel):
  Jetson → autossh → VPS nginx :8080 → интернет
```

---

## Структура проекта

```
nasa-home-cloud/
├── AGENTS.md              ← правила для агентов (критично!)
├── PROJECT_CONTEXT.md     ← зафиксированные решения
├── config/.env.example    ← шаблон всех переменных
├── docker/compose/        ← 5 Compose-файлов
├── docs/
│   ├── decisions/         ← ADR-0001..ADR-0004
│   ├── plans/             ← VPS, Tailscale
│   └── 18_NAS_RESEARCH_REPORT.md ← аналитика по NAS-проектам
├── scripts/
│   ├── backup/            ← restic + pg_dump
│   ├── diagnostics/       ← docker_health, storage_health + SMART
│   ├── network/           ← autossh tunnel
│   └── storage/           ← setup_disk, benchmark_io
├── systemd/               ← health timer, tunnel service
├── tests/                 ← test_samba_config, test_mount
└── docs/prompts/               ← промпты агентов по этапам
```

---

## Три USB-инцидента, или как системе дали надёжность

Это центральный сюжет — не архитектура, а реальные поломки.

**Инцидент 1 (2026-06-23) — error -71**

Ночью пришёл алерт в Telegram. SSD исчез с USB-шины, Docker упал, данные недоступны. В `dmesg` — `usb 2-1.3: USB disconnect, device number 3` и `sd 0:0:0:0: [sda] tag#0 FAILED Result: hostbyte=DID_ERROR`. Причина: Linux по умолчанию переводит USB-устройства в autosuspend через 2 секунды простоя. RTL9210B-CG не умел выходить из autosuspend без физического переподключения.

Решение: `usbcore.autosuspend=-1` в `extlinux.conf` (kernel params), SCSI timeout 120s через udev-правило.

**Инцидент 2 (2026-06-26) — порт 4 аппаратно сломан**

После очередного `error -71` выяснилось: порт 4 на USB-хабе физически не обеспечивает достаточно тока. Решение простое — переткнуть кабель в порт 2. Теперь watchdog мониторит именно порт 2.

**Инцидент 3 (незаметный) — CRLF в bash shebang**

Watchdog-скрипт был написан на Windows и закоммичен через git. При клоне на Jetson `#!/bin/bash` превратился в `#!/bin/bash\r` — невалидный shebang. Скрипт отказывался запускаться, но молчал. Системный watchdog не работал 4+ часов.

Решение: `.gitattributes` с `*.sh text eol=lf` — после этого git перестал конвертировать LF→CRLF.

**RTL9210B-CG → JMS583 (2026-06-28)**

Через 5 дней нестабильной работы пришёл вывод: RTL9210B-CG деградировал USB 3.0 до USB 2.0 (~40 MB/s), блокировал SMART-данные. Заказал JMS583 (Realtek JMS583 чип, отдельный класс).

Результат после замены: Write **250 MB/s**, Read **172 MB/s**. SMART стал читаться. Нет ни одного `error -71` после замены.

```
dmesg | grep usb-storage
# До (RTL9210B-CG):
# usb 2-1.3: new high-speed USB device (USB 2.0!)
# После (JMS583):
# usb 2-1.3: new SuperSpeed USB device (USB 3.0, 5 Gbps)
```

Но JMS583 с UAS-режимом не дружит с Jetson kernel 4.9 — нужен quirk:

```
# /boot/extlinux/extlinux.conf
APPEND ... usb-storage.quirks=152d:a583:u usbcore.autosuspend=-1
```

После этого `u` (usb-storage BOT mode) — скорость записи выросла с 8 MB/s до 250 MB/s.

**Итог инженерной работы по USB:**
- `nasa-usb-preboot.service` — power cycle USB-порта при каждом boot (до монтирования)
- `nasa-usb-monitor.service` — dmesg watcher, Telegram alert при первом `error -71`
- `nasa-ssd-recovery.service` — udev hotplug: подключил кабель → система сама монтирует, запускает preflight, поднимает Docker

---

## Семья подключилась: Talk и NASA API

Когда система стала стабильной, я добавил семью.

**Nextcloud Talk «Семья»**

Nextcloud Talk — встроенный мессенджер. Создал группу «Семья» (5 человек: admin, olga, ivan, ulyana, anna). История переписки хранится на нашем SSD, не в облаке Telegram.

![Nextcloud Talk — чат «Семья»](../../assets/screenshots/article/nextcloud_talk.png)

Каждому члену семьи отправил `docs/clients/` — персональную памятку на 1 страницу с URL, логином, шагами настройки на Android.

**NASA API v0.6.0 — 20 эндпоинтов**

Параллельно я попросил Claude Code построить REST API поверх всего стека. Зачем? Чтобы можно было скриптовать действия, смотреть статистику и управлять контейнерами без SSH.

| Группа | Эндпоинты | Что делает |
|---|---|---|
| Health/System | `/healthcheck`, `/v1/status`, `/v1/metrics`, `/v1/containers` | Состояние системы |
| Auth | `POST /api/auth/login`, `GET /api/auth/me` | JWT через Nextcloud OCS |
| Storage | `GET /v1/storage` | Диск, монтирование |
| Talk | `GET /v1/talk/rooms`, `POST /v1/talk/notify` | Чат «Семья» |
| Users | `GET /v1/users`, `POST /v1/users/{id}/notify` | Семейные пользователи |
| Photos | `GET /v1/photos/stats` | Immich: 6484 фото, 210 видео, 4.24 GB |
| Actions | `POST /v1/actions/containers/{name}/restart` | Перезапуск контейнеров |

Промпт, с которого начался API:

```
Создай FastAPI сервис nasa-api. Пусть он умеет авторизоваться 
через Nextcloud OCS, читать состояние Docker-контейнеров, 
отправлять сообщения в Talk и показывать статистику Immich.
JWT токен — от Nextcloud. Swagger UI обязателен.
```

Агент написал 9 роутеров, pydantic-модели, конфиг через pydantic-settings, JWT middleware и Swagger с примерами. Всё живёт в `services/nasa-api/`.

---

## Что сейчас работает

![Immich — фотоархив семьи (6.1 GiB, 228 GB свободно)](../../assets/screenshots/article/immich_web.png)

![Nextcloud — дашборд](../../assets/screenshots/article/nextcloud_dashboard.png)

Telegram daily report в 09:00 показывает: 13 контейнеров ✅, LOCAL HTTP ✅, EXTERNAL ACCESS ✅, Beszel ✅.

![Beszel Hub — обзор систем: Jetson Nano + VPS Vienna](../../assets/screenshots/article/beszel_systems_overview.png)

![Beszel Hub — метрики Jetson Nano: CPU 14–19%, RAM 2.3 GB, Docker containers](../../assets/screenshots/article/beszel_jetson_metrics.png)

![NASA API v0.6.0 — Swagger UI: Talk, Users, Photos, Actions](../../assets/screenshots/article/nasa_api_swagger.png)

---

## Честная оценка подхода

**Плюсы:**
- **Скорость** — недели превратились в часы
- **Документация** — ADR, CHANGELOG, двуязычные доки — агент пишет это параллельно с кодом. Я бы сам так не делал
- **Ошибки зафиксированы** — VPN-инцидент, CGNAT-сюрприз, exec-bit на Windows — всё в ADR и постмортемах
- **GitHub-стандарт** — `.github/`, CI, badge-линейка, CODEOWNERS — агент знает нормы

**Минусы:**
- Агент **не знает ваше железо** — нужно объяснять детали (USB-SATA мост, реальное RAM)
- **Финальная проверка — ваша** — firewall, fstab, пароли надо читать самому
- **Контекст сессии кончается** — решается хорошим `AGENTS.md` и `PROJECT_CONTEXT.md`

---

## Ключевой инсайт

`AGENTS.md` — это не просто документ. Это **память агента между сессиями**. Там зафиксированы ограничения железа, жёсткие правила (Amnezia не трогать), архитектурные решения и рабочий процесс. Агент читает его при старте каждой сессии и не повторяет прошлые ошибки.

Если вы строите что-то с AI-агентом — начинайте с написания этого файла.

---

**Текущий статус (v1.4.0, 2026-06-29):** Система полностью работает. JMS583 подключён (Write 250 MB/s). Семья использует чат «Семья» в Nextcloud Talk. NASA API v0.6.0 — Talk/Users/Photos/Actions эндпоинты в Swagger. goss 40/40.

**Следующая статья:** Restic off-site backup, Ollama local AI на Jetson, GitHub metrics.

**GitHub:** [AlexeyBorovskoy/Nasa_home](https://github.com/AlexeyBorovskoy/Nasa_home) — промпты, ADR, Docker Compose, скрипты, памятки пользователей — всё открыто.
