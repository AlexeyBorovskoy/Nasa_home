# External Docs Local Cache

## 1. Назначение

Этот manifest описывает локально скачанные внешние материалы для автономной
работы с проектом NASA Home Cloud.

Локальный cache:

```text
external_docs/
```

Каталог `external_docs/` исключён из Git через `.gitignore`. В публичный
репозиторий попадает только этот manifest и список ссылок.

## 2. Что скачано

Дата cache-среза: 2026-05-31.

| Каталог | Содержание | Назначение |
|---|---|---|
| `external_docs/jatson/` | локальный SD image, Etcher, NVIDIA User Guide PDF, исходный reference-файл | Stage 0: microSD и первый boot |
| `external_docs/jetson/` | NVIDIA Getting Started, L4T index, Jetson reference links | Stage 0: официальная HTML-документация |
| `external_docs/docker/` | Docker Engine Ubuntu, Compose plugin, Compose file reference, post-install | установка Docker/Compose на Jetson |
| `external_docs/nextcloud/` | Nextcloud admin/system/WebDAV pages, link manifest | Nextcloud Stage 1B |
| `external_docs/nextcloud/groupware/` | Contacts, Calendar, DAVx5 pages, link manifest | DAVx5/CalDAV/CardDAV сценарии |
| `external_docs/immich/` | Immich requirements, install, backup, mobile backup, latest compose/env | Immich Stage 1C |
| `external_docs/deepseek/` | API quick start, pricing, chat completion, reasoning, JSON, tools, cache | LLM Gateway Stage 1D |
| `external_docs/protocols/` | RFC 4918, 4791, 6352, 5545, 6350 | WebDAV/CalDAV/CardDAV/iCalendar/vCard |
| `external_docs/nas/` | Samba smb.conf, OpenSSH manual, sshd_config | Samba/SFTP |
| `external_docs/backup/` | restic index, repository, backup, restore, forget pages | Backup/restore Stage 1E |
| `external_docs/alternatives/` | link manifest for alternatives | архитектурное сравнение |

После загрузки cache содержит 52 файла. Пустых файлов не найдено.

## 3. Что намеренно не скачано

Не скачивались:

- `nextcloud-documentation-master.zip`;
- `nextcloud-docker-master.zip`;
- `immich-main.zip`;
- `restic-master.zip`;
- ZIP-архивы альтернативных проектов.

Причина: это большие и быстро устаревающие копии репозиториев. Для текущего
этапа достаточно официальных HTML-страниц, RFC-файлов, ссылок и актуальных
Immich `docker-compose.yml` / `example.env`.

## 4. Полезные локальные файлы первого порядка

Stage 0:

```text
external_docs/jatson/jetson-nano-jp461-sd-card-image.zip
external_docs/jatson/balenaEtcher-linux-x64-2.1.6.zip
external_docs/jatson/NV_Jetson_Nano_Developer_Kit_User_Guide.pdf
external_docs/jetson/get-started-jetson-nano-devkit.html
```

Docker:

```text
external_docs/docker/docker-engine-ubuntu.html
external_docs/docker/docker-compose-linux.html
external_docs/docker/docker-linux-postinstall.html
```

Immich:

```text
external_docs/immich/immich-docker-compose.yml
external_docs/immich/immich-example.env
external_docs/immich/requirements.html
external_docs/immich/docker-compose-install.html
external_docs/immich/backup-and-restore.html
```

Protocols:

```text
external_docs/protocols/rfc4918-webdav.txt
external_docs/protocols/rfc4791-caldav.txt
external_docs/protocols/rfc6352-carddav.txt
external_docs/protocols/rfc5545-icalendar.txt
external_docs/protocols/rfc6350-vcard.txt
```

Backup:

```text
external_docs/backup/restic-030-preparing-repo.html
external_docs/backup/restic-040-backup.html
external_docs/backup/restic-050-restore.html
external_docs/backup/restic-060-forget.html
```

## 5. Checksums

Для локального контроля создан ignored-файл:

```text
external_docs/SHA256SUMS.local
```

Его можно пересоздать командой:

```bash
cd /home/alexey/work/NASA
sha256sum $(find external_docs -type f | sort) > external_docs/SHA256SUMS.local
```

Jetson SD image и Etcher checksums отдельно зафиксированы в
`docs/references/JETSON_LOCAL_ASSETS.md`.

## 6. Обновление cache

Для повторной загрузки облегчённого набора используется:

```bash
./scripts/fetch_external_docs.sh
```

Скрипт не скачивает тяжёлые repo ZIP и не скачивает Jetson SD Card Image. SD
image уже лежит локально в `external_docs/jatson/` и должен обновляться только
вручную, если это действительно нужно.

## 7. Правила безопасности

- Не добавлять `external_docs/` в Git.
- Не хранить в `external_docs/` реальные `.env`, ключи, токены, дампы или
  персональные файлы.
- Не публиковать локальные копии сторонних бинарников.
- Перед использованием скачанных HTML-страниц для решений, которые могли
  измениться, сверять критичные детали с официальным сайтом.
