# Домашнее облако на NVIDIA Jetson Nano: заменяю Google Photos, Drive и ChatGPT за 0 $/мес

> **Статус проекта (июнь 2026):** система собрана и задокументирована, идёт тестовое развёртывание на реальном железе. GitHub: [AlexeyBorovskoy/Nasa_home](https://github.com/AlexeyBorovskoy/Nasa_home)

Несколько месяцев назад у меня на полке лежал NVIDIA Jetson Nano Developer Kit, купленный когда-то для экспериментов с ML. После того как Google Photos урезал бесплатное хранилище, а потом ещё и поднял цены на Workspace — я решил, что хватит кормить подписками чужих дядей, которые сканируют мои фотографии.

Так появился **NASA** (Not Another Storage Appliance) — семейное домашнее облако на Jetson Nano + внешний HDD.

<cut>

## Зачем вообще это всё?

Боли, которые я хотел закрыть:

- **Google Photos** — бесплатная версия закончилась. Семейный архив 300+ GB фото и видео надо куда-то перенести.
- **Google Drive / Nextcloud** — документы, фото с телефонов, резервные копии контактов.
- **ChatGPT** — использую для рабочих задач, но передавать через него рабочие тексты и переписку некомфортно. Хочу свой прокси, который не логирует лишнее.
- **Приватность** — семейные фото не должны лежать на серверах компаний, которые монетизируют данные.

**Итоговый стек:**

| Сервис | Замена | RAM |
|--------|--------|-----|
| Nextcloud | Google Drive, OneDrive | ~200 MB |
| Immich | Google Photos | ~300 MB (ML отключён) |
| LLM Gateway | ChatGPT API proxy | ~80 MB |
| Netdata + Uptime Kuma | - (мониторинг) | ~220 MB |

Итого: ~800 MB на Jetson Nano с 4 GB RAM. Остаётся запас.

---

## Железо

- **NVIDIA Jetson Nano Developer Kit** — куплен за ~59$ в своё время, сейчас можно найти б/у за 40-60$. ARM64, 4 GB LPDDR4, GPU Maxwell (не нужен для этого проекта).
- **microSD 32 GB** — для ОС (Ubuntu 18.04 L4T).
- **Внешний USB HDD** — основное хранилище. Все данные живут на нём, не на SD-карте.
- **Ethernet** — подключён напрямую в роутер. Wi-Fi не использую (надёжность).
- **VPS в Европе** — для внешнего доступа через reverse SSH tunnel (CGNAT не пускает входящие напрямую).

**Важное ограничение Jetson Nano:** нет swap-раздела (eMMC-специфика Developer Kit). Значит, суммарное потребление RAM не должно превышать ~3.5 GB. Поэтому Immich запускается с `IMMICH_DISABLE_MACHINE_LEARNING=true` — иначе ML-процессы кушают лишние 500+ MB.

---

## Архитектура

```
Телефоны Android (LAN)                Телефоны (интернет)
      │ Nextcloud App                         │
      │ Immich App                            ▼ (port 8080)
      │ DAVx5 (Stage 2)               VPS nginx (Вена)
      │                                       │ reverse SSH tunnel
      ▼                                       │ (Jetson инициирует — CGNAT обходится)
   Jetson Nano 192.168.0.50                   │
   ┌─────────────────────────────────────┐    │
   │  homecloud_nextcloud   :8080  ◄─────┘    │
   │  homecloud_immich_server :2283            │
   │  homecloud_llm_gateway  :8090            │
   │  homecloud_nextcloud_db (postgres)        │
   │  homecloud_immich_db    (postgres)        │
   │  homecloud_*_redis                        │
   └─────────────────────────────────────┘
              │
              ▼
        /mnt/storage (USB HDD, ext4)
        ├── nextcloud/data/
        ├── immich/library/
        ├── db/nextcloud-postgres/
        ├── db/immich-postgres/
        └── backups/
```

---

## Что получилось: ключевые технические решения

### 1. Docker Compose — один файл на весь стек

Вместо ручной установки сервисов — всё в Docker. Один `docker-compose.stage1.yml` поднимает 8 контейнеров:

```yaml
name: homecloud

services:
  nextcloud-db:
    image: postgres:15-alpine
    container_name: homecloud_nextcloud_db
    environment:
      POSTGRES_DB: nextcloud
      POSTGRES_USER: ${POSTGRES_NEXTCLOUD_USER}
      POSTGRES_PASSWORD: ${POSTGRES_NEXTCLOUD_PASSWORD}
    volumes:
      - ${STORAGE_ROOT}/db/nextcloud-postgres:/var/lib/postgresql/data
    restart: unless-stopped

  nextcloud:
    image: nextcloud:28-apache
    container_name: homecloud_nextcloud
    depends_on:
      - nextcloud-db
      - nextcloud-redis
    environment:
      NEXTCLOUD_TRUSTED_DOMAINS: "192.168.0.50 nextcloud.local"
      NEXTCLOUD_DATA_DIR: /mnt/nc-data
    volumes:
      - ${STORAGE_ROOT}/nextcloud/data:/mnt/nc-data
    ports:
      - "8080:80"
    restart: unless-stopped
```

Все пароли — в `config/.env` (gitignored). В репозитории только `config/.env.example` с описанием переменных.

### 2. LLM Gateway — приватный прокси для DeepSeek

Не хочу, чтобы рабочие тексты уходили напрямую в API. Написал FastAPI-прокси, который:
- Очищает запросы от email, телефонов, токенов (regex-маски)
- Логирует только метаданные (длина, provider, latency)
- В mock-режиме работает без реального API-ключа
- Поддерживает суточный лимит токенов (`LLM_DAILY_TOKEN_LIMIT`)

```python
# services/llm-gateway/app/main.py (фрагмент)
REDACT_PATTERNS = {
    "email": r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}",
    "phone_ru": r"\+7[\s\-]?\(?\d{3}\)?[\s\-]?\d{3}[\s\-]?\d{2}[\s\-]?\d{2}",
    "api_key": r"(sk-|Bearer\s)[A-Za-z0-9\-_]{20,}",
}
```

### 3. Обход CGNAT через reverse SSH tunnel

Jetson Nano за домашним роутером — входящих подключений нет из-за CGNAT. Tailscale решает это элегантно, но мы пошли другим путём: **autossh reverse tunnel через VPS**.

Jetson инициирует исходящее SSH-соединение на VPS и пробрасывает порты:

```bash
autossh -N \
  -R 18080:localhost:8080 \   # Nextcloud
  -R 12283:localhost:2283 \   # Immich
  -R 18090:localhost:8090 \   # LLM Gateway
  -o ServerAliveInterval=30 \
  root@$VPS_HOST
```

На VPS nginx проксирует `port 8080 → localhost:18080` и т.д. Systemd-сервис `nasa-tunnel.service` автоматически пересоединяется при разрыве.

### 4. Почему не Zabbix и не другие «промышленные» решения?

Zabbix требует отдельную PostgreSQL (~500 MB RAM + процессор). На Jetson Nano без swap это означает OOM-killer. Взял минималистичный стек:

- **Netdata** — real-time метрики CPU/RAM/GPU/контейнеров (~100 MB)
- **Uptime Kuma** — статус сервисов + алерты в Telegram (~60 MB)
- **Portainer CE** — управление контейнерами через браузер (~60 MB)

---

## Проблемы, которые встретил

### Amnezia VPN — чуть не уронил 25 клиентов

На VPS уже работает Amnezia VPN, которым пользуется вся семья. По неопытности я попытался изменить WireGuard-конфигурацию через SSH — это рестартует контейнер и кладёт всех клиентов. Потратил 40 минут на восстановление.

**Урок:** задокументировал в `ADR-0003` и `AGENTS.md` жёсткое правило: Amnezia не трогать через SSH/`wg set`, только через десктоп-приложение.

### exec-bit шум в Git на Windows

Проект редактирую с Windows-хоста, Jetson на Linux. `git status` показывает сотни «изменённых» файлов из-за расхождения в execute-бите (100755 → 100644). Решение в `.gitconfig`:

```
[core]
    fileMode = false
```

Добавил в `docs/plans/` отдельный раздел об этой ловушке.

### CGNAT — полная неожиданность

Думал, что WireGuard на VPS даст внешний доступ. Нет — роутер оператора сидит за CGNAT, публичного IP у Jetson нет вообще. WireGuard работает только от клиента к серверу, но не наоборот. Пришлось изучать Tailscale и reverse SSH tunnel.

---

## Текущий статус и что дальше

**Сделано:**
- ✅ Docker Compose для всех сервисов (тестировано локально)
- ✅ Reverse SSH tunnel архитектура (VPS настроен)
- ✅ LLM Gateway с privacy-фильтром
- ✅ Скрипты резервного копирования (restic + pg_dump)
- ✅ Мониторинг стек (compose готов)
- ✅ Документация на русском и английском (17 файлов)
- ✅ GitHub Actions: CI для проверки секретов и валидации compose

**В работе:**
- 🔧 Подключение USB HDD и финальный запуск на Jetson
- 🔧 Перенос 300 GB семейного архива с Google Photos в Immich
- 🔧 Настройка autossh systemd-сервиса

**Планируется (Stage 2):**
- Tailscale для резервного внешнего доступа
- Android-клиенты (DAVx5, Nextcloud App, Immich App)
- Résume ollama или LLaMA-cpp для локального LLM (если RAM позволит)

---

## Репозиторий

Весь проект открыт на GitHub: **[AlexeyBorovskoy/Nasa_home](https://github.com/AlexeyBorovskoy/Nasa_home)**

Там есть:
- 17 документов (RU+EN) по каждому этапу
- Готовые Docker Compose файлы
- Промпты для агентов (Claude Code / Codex) — проект изначально проектировался с расчётом на AI-assisted development
- ADR-документы (Architecture Decision Records)
- CI/CD для проверки секретов

Буду рад вопросам и звёздочкам — проект живой, обновляется по мере продвижения.

---

**Теги:** #selfhosted #nextcloud #immich #jetson-nano #docker #homelab #privacy #deepseek #fastapi

**Хабы:** Системное администрирование, Open Source, Разработка под Linux, Хранение данных