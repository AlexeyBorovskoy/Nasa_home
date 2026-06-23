# 00. Обзор проекта

## 1. Концепция

Проект представляет собой инженерный шаблон домашней облачной платформы для семьи. Основной фокус — практическая замена части функций Google/Xiaomi Cloud с использованием открытых решений и собственного оборудования.

## 2. Основные функции

| Функция | Компонент |
|---|---|
| Файлы и документы | Nextcloud |
| Контакты | Nextcloud Contacts + DAVx5 |
| Календарь | Nextcloud Calendar + DAVx5 |
| Фото/видео с телефонов | Immich |
| Локальная файловая шара | Samba |
| Технический доступ | SFTP/SSH |
| Резервное копирование | restic/borg + DB dumps |
| AI-помощник администратора | DeepSeek API через LLM Gateway |
| Будущий центр восстановления Android | Android Stage 2 + Backup API |

## 3. Почему не готовый NAS

Готовые NAS удобны, но проект ориентирован на:

- повторное использование имеющегося Jetson Nano;
- образовательную и инженерную ценность;
- прозрачный контроль над сервисами;
- возможность публикации open-source шаблона;
- расширение до собственного Android-клиента и LLM-шлюза.

## 4. Почему не локальная LLM

Jetson Nano ограничен по RAM/CPU. На первом этапе локальная LLM не разворачивается. LLM-функции ограничены административными сценариями через внешний DeepSeek API.

## 5. Предварительная оценка возможности «взлёта» проекта

Проект может быть востребован, если позиционировать его не как очередной `docker-compose for Nextcloud`, а как:

```text
Self-hosted family cloud blueprint for low-power ARM devices
with Android recovery roadmap and privacy-controlled LLM gateway.
```

Ключевая отличительная особенность — связка **Nextcloud + Immich + Android Restore Roadmap + LLM Privacy Gateway + Codex-ready documentation**.

## 6. Текущее операционное состояние

На 2026-06-23 проект находится в Stage 1 partial recovery после USB storage
incident: Jetson доступен через VPS reverse SSH tunnel, SSD снова смонтирован в
`/mnt/storage`, `e2fsck -f -n` и `storage_preflight.sh` проходят чисто. Immich,
LLM Gateway, nasa-api, Samba, мониторинг, backup и Nextcloud работают.
Nextcloud прошёл read-only review и controlled start: `status.php` возвращает
`HTTP 200`, `maintenance=false`, `needsDbUpgrade=false`.

Корневой документ инцидента:
`docs/plans/STORAGE_INCIDENT_2026-06-23.md`.
