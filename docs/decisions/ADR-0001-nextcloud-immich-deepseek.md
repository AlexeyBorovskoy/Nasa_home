# ADR-0001: Выбор Nextcloud + Immich + DeepSeek Gateway
# ADR-0001: Choosing Nextcloud + Immich + DeepSeek Gateway

## Статус / Status

🇷🇺 Принято. / 🇬🇧 Accepted.

## Контекст / Context

🇷🇺 Необходимо создать домашнее семейное облако на Jetson Nano + USB HDD.
🇬🇧 Need to build a home family cloud on Jetson Nano + USB HDD.

## Решение / Decision

🇷🇺 Использовать:
🇬🇧 Use:

- 🇷🇺 Nextcloud для файлов, документов, контактов и календаря / 🇬🇧 Nextcloud for files, documents, contacts and calendar
- 🇷🇺 Immich для фото и видео / 🇬🇧 Immich for photos and videos
- 🇷🇺 DeepSeek API через LLM Gateway для административных LLM-функций / 🇬🇧 DeepSeek API via LLM Gateway for administrative LLM functions
- 🇷🇺 не использовать локальную LLM на первом этапе / 🇬🇧 no local LLM on Stage 1

## Последствия / Consequences

### Плюсы / Pros

- 🇷🇺 готовые Android-клиенты / 🇬🇧 ready-made Android clients
- 🇷🇺 понятная архитектура / 🇬🇧 clear architecture
- 🇷🇺 низкая нагрузка по AI на Jetson / 🇬🇧 low AI load on Jetson
- 🇷🇺 возможность публикации проекта / 🇬🇧 project can be made public
- 🇷🇺 расширяемость до собственного Android-клиента / 🇬🇧 extensible to custom Android client

### Минусы / Cons

- 🇷🇺 внешняя LLM требует privacy-фильтра / 🇬🇧 external LLM requires privacy filter
- 🇷🇺 Immich на 4 GB RAM требует отключения ML / 🇬🇧 Immich on 4 GB RAM requires ML disabled
- 🇷🇺 Nextcloud требует аккуратной настройки БД/Redis/cron / 🇬🇧 Nextcloud requires careful DB/Redis/cron setup
- 🇷🇺 для настоящего backup нужен второй носитель / 🇬🇧 true backup requires a second medium
