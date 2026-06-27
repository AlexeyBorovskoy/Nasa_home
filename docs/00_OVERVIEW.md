# 00. Обзор проекта / Project Overview

## 1. Концепция / Concept

🇷🇺 Проект представляет собой инженерный шаблон домашней облачной платформы для семьи. Основной фокус — практическая замена части функций Google/Xiaomi Cloud с использованием открытых решений и собственного оборудования.

🇬🇧 This project is an engineering template for a family home cloud platform. The main focus is a practical replacement for parts of Google/Xiaomi Cloud functionality using open-source solutions and owned hardware.

## 2. Основные функции / Core Features

| Функция / Feature | Компонент / Component |
|---|---|
| Файлы и документы / Files & documents | Nextcloud |
| Контакты / Contacts | Nextcloud Contacts + DAVx5 |
| Календарь / Calendar | Nextcloud Calendar + DAVx5 |
| Фото/видео с телефонов / Photos & video from phones | Immich |
| Локальная файловая шара / Local file share | Samba |
| Технический доступ / Technical access | SFTP/SSH |
| Резервное копирование / Backups | restic/borg + DB dumps |
| AI-помощник администратора / AI admin assistant | DeepSeek API via LLM Gateway |
| Будущий центр восстановления Android / Future Android restore hub | Android Stage 2 + Backup API |

## 3. Почему не готовый NAS / Why not a ready-made NAS

🇷🇺 Готовые NAS удобны, но проект ориентирован на:

- повторное использование имеющегося Jetson Nano;
- образовательную и инженерную ценность;
- прозрачный контроль над сервисами;
- возможность публикации open-source шаблона;
- расширение до собственного Android-клиента и LLM-шлюза.

🇬🇧 Ready-made NAS appliances are convenient, but this project aims for:

- reusing the existing Jetson Nano instead of buying new hardware;
- educational and engineering value;
- transparent control over all services;
- the ability to publish an open-source template;
- extension to a custom Android client and LLM gateway.

## 4. Почему не локальная LLM / Why not a local LLM

🇷🇺 Jetson Nano ограничен по RAM/CPU. На первом этапе локальная LLM не разворачивается. LLM-функции ограничены административными сценариями через внешний DeepSeek API.

🇬🇧 Jetson Nano is limited in RAM and CPU. In Stage 1, no local LLM is deployed. LLM functions are restricted to admin scenarios via the external DeepSeek API.

## 5. Позиционирование / Positioning

🇷🇺 Проект может быть востребован, если позиционировать его не как очередной `docker-compose for Nextcloud`, а как:

```text
Self-hosted family cloud blueprint for low-power ARM devices
with Android recovery roadmap and privacy-controlled LLM gateway.
```

Ключевая отличительная особенность — связка **Nextcloud + Immich + Android Restore Roadmap + LLM Privacy Gateway + Codex-ready documentation**.

🇬🇧 The project's value is strongest when positioned not as "yet another Nextcloud docker-compose" but as:

```text
Self-hosted family cloud blueprint for low-power ARM devices
with Android recovery roadmap and privacy-controlled LLM gateway.
```

Key differentiator: the combination of **Nextcloud + Immich + Android Restore Roadmap + LLM Privacy Gateway + Codex-ready documentation**.

## 6. Текущее операционное состояние / Current Operational State

🇷🇺 На 2026-06-27 проект находится в Stage 1 fully operational: Jetson доступен через VPS reverse SSH tunnel, SSD смонтирован в `/mnt/storage`, все 13 контейнеров `Up (healthy)`. USB-мост RTL9210B-CG деградирует USB 3.0→2.0 и блокирует SMART. Замена на JMS583 ожидается 2026-06-28. USB watchdog ⚠️ ОСТАНОВЛЕН до замены.

🇬🇧 As of 2026-06-27 the project is in Stage 1 fully operational: Jetson accessible via VPS reverse SSH tunnel, SSD mounted at `/mnt/storage`, all 13 containers `Up (healthy)`. RTL9210B-CG USB bridge degrades USB 3.0→2.0 and blocks SMART passthrough. JMS583 replacement enclosure expected 2026-06-28. USB watchdog ⚠️ STOPPED until swap.

Incident log / Лог инцидента: [docs/plans/STORAGE_INCIDENT_2026-06-23.md](plans/STORAGE_INCIDENT_2026-06-23.md).
