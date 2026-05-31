# 06. Nextcloud

## 1. Роль в проекте

Nextcloud отвечает за:

- файлы;
- документы;
- WebDAV;
- пользователей семьи;
- общие папки;
- контакты;
- календарь;
- Android-доступ.

Официальная документация Nextcloud указывает, что Nextcloud поддерживает WebDAV и доступ к файлам через WebDAV-клиенты, а рекомендуемый способ синхронизации Android/iOS — официальные мобильные приложения Nextcloud.

## 2. Клиентские сценарии

| Клиент | Способ доступа |
|---|---|
| Android | Nextcloud Android |
| Windows | Web UI, WebDAV, SMB через отдельную шару |
| Linux | Web UI, WebDAV, SFTP |
| Семейные пользователи | отдельные аккаунты Nextcloud |

## 3. Contacts/Calendar

Рекомендуемая связка:

```text
Nextcloud Contacts
Nextcloud Calendar
DAVx5 на Android
```

## 4. Данные

```text
/mnt/storage/nextcloud/data
/mnt/storage/db/nextcloud-postgres
```

## 5. Минимальная проверка

1. Открыть web-интерфейс.
2. Создать пользователя.
3. Загрузить тестовый файл.
4. Подключить Android Nextcloud.
5. Проверить WebDAV.
6. Установить Contacts/Calendar apps.
7. Подключить DAVx5.

## 6. Эксплуатационное правило

Nextcloud разворачивается до Immich. После стабилизации Nextcloud включается Immich.
