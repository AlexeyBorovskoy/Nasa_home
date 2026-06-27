# 15. Обзор готовых self-hosted решений / Self-hosted Solutions Review

## 1. Вывод / Conclusion

🇷🇺 Подобные решения существуют, но обычно закрывают только часть задачи. Отличие данного проекта — не в уникальности каждого компонента, а в интеграционном шаблоне: **семейное облако + фотоархив + Android restore roadmap + DeepSeek LLM Gateway + Codex-ready инженерная документация**.

🇬🇧 Similar solutions exist but typically cover only part of the task. This project's differentiation is not in the uniqueness of each component, but in the integration pattern: **family cloud + photo archive + Android restore roadmap + DeepSeek LLM Gateway + Codex-ready engineering documentation**.

## 2. Сравнительная таблица / Comparison table

| Решение / Solution | Категория / Category | Сильные стороны / Strengths | Ограничения / Limitations | Роль в проекте / Role |
|---|---|---|---|---|
| Nextcloud | Облако/PIM / Cloud/PIM | файлы, WebDAV, календарь, контакты / files, WebDAV, calendar, contacts | требует настройки / requires setup | основной компонент / main component |
| Immich | Фото/видео / Photo/video | mobile backup, web gallery, UX like Google Photos | требует RAM, ML тяжёлый / RAM-heavy, ML heavy | основной компонент, ML off / main component, ML off |
| Seafile | Файлы / Files | быстрая синхронизация / fast sync, efficient | меньше PIM/экосистемы / less PIM/ecosystem | альтернатива / alternative |
| Syncthing | P2P sync | простота / simplicity, no central server | нет полноценного облака / no full cloud | доп. синхронизация / additional sync |
| OpenMediaVault | NAS OS | web UI, SMB/NFS/FTP/SSH, ARM | может конфликтовать / may conflict with custom stack | альтернатива / alternative |
| PhotoPrism | Фотоархив / Photo archive | каталогизация / cataloguing, metadata | тяжеловат / heavy, no focus on mobile backup | альтернатива Stage 3 / Stage 3 alternative |
| Piwigo/Lychee | Web-галерея / Web gallery | лёгкие галереи / lightweight | not full mobile backup | не основной / not primary |
| TrueNAS | NAS | ZFS, enterprise | нецелесообразен для Jetson Nano / not suitable for Jetson | не использовать / do not use |
| Open WebUI | LLM UI | универсальный / universal LLM interface | локальная LLM / local LLM not used | Stage 3 |
| Home Assistant | Умный дом / Home automation | умный дом / smart home | не решает облако/backup / doesn't solve cloud/backup | вне ядра / out of scope |

## 3. Почему Nextcloud и Immich / Why Nextcloud and Immich

🇷🇺 Nextcloud закрывает PIM и файловое облако. Immich лучше подходит для фото/видео с телефонов. В паре они дают функциональность, близкую к Google Drive + Google Photos, но на собственном сервере.

🇬🇧 Nextcloud covers PIM and file cloud. Immich is better suited for phone photos/video. Together they match Google Drive + Google Photos functionality, but on your own server.

## 4. Почему не Seafile как основной / Why not Seafile as primary

🇷🇺 Seafile хорош для файловой синхронизации, но хуже подходит как семейная платформа с календарями, контактами и расширяемыми приложениями.
🇬🇧 Seafile is good for file sync, but worse as a family platform with calendars, contacts, and extensible apps.

## 5. Почему не только Syncthing / Why not Syncthing alone

🇷🇺 Syncthing отлично синхронизирует папки, но не даёт web-облако, пользователей, семейные shared folders, календарь и контакты.
🇬🇧 Syncthing excels at folder sync, but doesn't provide a web cloud, users, family shared folders, calendar, or contacts.

## 6. Почему не OpenMediaVault как ядро / Why not OpenMediaVault as core

🇷🇺 OMV удобен как NAS-панель и ориентирован на NAS-сценарии с ARM-поддержкой. Но данный проект требует гибкой сервисной архитектуры с Nextcloud, Immich, Android API и LLM Gateway. OMV оставлен как альтернативный путь.
🇬🇧 OMV is convenient as a NAS panel and is ARM-supported. But this project requires a flexible service architecture with Nextcloud, Immich, Android API, and LLM Gateway. OMV remains an alternative path.

## 7. Возможность публичного развития / Potential for public growth

```text
Home cloud blueprint for old SBC/ARM boards, focused on family Android backup
and privacy-controlled AI administration.
```

🇷🇺 Чтобы проект «взлетел», нужно добавить:
🇬🇧 For the project to grow, add:

1. 🇷🇺 реально проверенные install scripts / 🇬🇧 genuinely tested install scripts
2. 🇷🇺 поддержку Raspberry Pi 4/5, mini-PC, старых ноутбуков / 🇬🇧 support for Raspberry Pi 4/5, mini-PC, old laptops
3. 🇷🇺 wizard для `.env` / 🇬🇧 `.env` wizard
4. 🇷🇺 CI-проверки YAML/scripts / 🇬🇧 CI checks for YAML/scripts
5. 🇷🇺 подробные скриншоты / 🇬🇧 detailed screenshots
6. 🇷🇺 инструкции для Android/Xiaomi/HyperOS / 🇬🇧 Android/Xiaomi/HyperOS instructions
7. 🇷🇺 демонстрационный режим без реальных секретов / 🇬🇧 demo mode without real secrets
8. 🇷🇺 понятную лицензию и CONTRIBUTING / 🇬🇧 clear license and CONTRIBUTING
