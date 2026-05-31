# 14. Test Plan

## 1. Hardware tests

| Тест | Команда | Критерий |
|---|---|---|
| RAM | `free -h` | система не в swap storm |
| Storage | `df -h /mnt/storage` | диск доступен |
| USB errors | `dmesg` | нет I/O/reset loop |
| SMART | `smartctl -a` | нет критичных ошибок |
| Stage 0 direct-link | `nmap -sn 192.168.1.0/24` | Jetson виден как отдельный host |
| Stage 0 SSH | `ssh <user>@<jetson-direct-link-ip>` | вход с ноутбука работает |
| Target LAN после переноса | `ping 192.168.0.50` | доступен после подключения к роутеру |

## 2. Samba/SFTP

| Тест | Критерий |
|---|---|
| Windows открывает шару | Да |
| Linux подключается по SFTP | Да |
| Запись тестового файла | Да |
| Права доступа корректны | Да |

## 3. Nextcloud

1. Вход в web-интерфейс.
2. Создание пользователя.
3. Загрузка файла.
4. Подключение Android-клиента.
5. Проверка Contacts/Calendar.
6. Проверка DAVx5.

## 4. Immich

1. Вход в web-интерфейс.
2. Подключение Android-клиента.
3. Загрузка 20–50 фото.
4. Загрузка 2–3 видео.
5. Проверка `docker stats`.
6. Проверка работы после перезапуска контейнеров.

## 5. LLM Gateway

1. `GET /health`.
2. Тест mock-mode.
3. Тест DeepSeek API без персональных данных.
4. Проверка лимитов.
5. Проверка redaction.

## 6. Backup/Restore

1. Создать тестовый backup.
2. Проверить список snapshots.
3. Восстановить в `/tmp/restore-test`.
4. Проверить целостность файлов.
