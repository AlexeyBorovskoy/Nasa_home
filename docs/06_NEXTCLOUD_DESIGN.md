# 06. Nextcloud

## 1. Роль в проекте / Role in the project

🇷🇺 Nextcloud отвечает за:
🇬🇧 Nextcloud handles:

- файлы / files
- документы / documents
- WebDAV
- пользователей семьи / family user accounts
- общие папки / shared folders
- контакты / contacts
- календарь / calendar
- Android-доступ / Android access

🇷🇺 Nextcloud поддерживает WebDAV и доступ к файлам через WebDAV-клиенты. Рекомендуемый способ синхронизации Android/iOS — официальные мобильные приложения Nextcloud.
🇬🇧 Nextcloud supports WebDAV and file access via WebDAV clients. The recommended Android/iOS sync method is the official Nextcloud mobile apps.

## 2. Клиентские сценарии / Client scenarios

| Клиент / Client | Способ доступа / Access method |
|---|---|
| Android | Nextcloud Android app |
| Windows | Web UI, WebDAV, SMB through separate share |
| Linux | Web UI, WebDAV, SFTP |
| Семейные пользователи / Family users | отдельные аккаунты / separate Nextcloud accounts |

## 3. Contacts/Calendar

🇷🇺 Рекомендуемая связка:
🇬🇧 Recommended setup:

```text
Nextcloud Contacts
Nextcloud Calendar
DAVx5 on Android
```

## 4. Данные / Data paths

```text
/mnt/storage/nextcloud/data
/mnt/storage/db/nextcloud-postgres
```

## 5. Минимальная проверка / Minimal check

🇷🇺
1. Открыть web-интерфейс.
2. Создать пользователя.
3. Загрузить тестовый файл.
4. Подключить Android Nextcloud.
5. Проверить WebDAV.

🇬🇧
1. Open web interface.
2. Create a user.
3. Upload a test file.
4. Connect Android Nextcloud client.
5. Verify WebDAV works.
