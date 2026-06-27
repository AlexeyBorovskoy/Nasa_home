# 09. Android Stage 2 Architecture

## 1. Цель Stage 2 / Stage 2 Goal

🇷🇺 Разработать собственное Android-приложение для синхронизации и восстановления пользовательских данных семьи. Stage 2 не заменяет системный backup Google/Xiaomi полностью, так как Android ограничивает доступ обычных приложений к системным данным.

🇬🇧 Develop a custom Android app for syncing and restoring family user data. Stage 2 does not fully replace the Google/Xiaomi system backup, since Android restricts regular app access to system data.

## 2. Что можно реализовать без root / What is possible without root

| Данные / Data | Реализация / Implementation |
|---|---|
| Фото/видео / Photos & video | Да / Yes |
| Документы / Documents | Да / Yes |
| Downloads | Да / Yes |
| Музыка / Music | Да / Yes |
| Контакты / Contacts | Да / Yes, через экспорт/vCard или CardDAV / via vCard export or CardDAV |
| Календарь / Calendar | Да / Yes, через iCal/CalDAV / via iCal/CalDAV |
| SMS | Частично / Partial, при разрешениях / with permissions |
| Журнал вызовов / Call log | Частично / Partial, при разрешениях / with permissions |
| Список приложений / App list | Да / Yes |
| APK | Частично / Partial |
| Данные приложений / App data | Обычно нет / Usually No |
| Wi-Fi пароли / Wi-Fi passwords | Нет / No — без системных прав/root / without system rights/root |
| Настройки Android / Android settings | Нет/частично / No/partial |

## 3. Модули приложения / App modules

```text
Android Backup Client
├── Auth Module
├── Device Registry
├── File Sync Engine
├── Media Backup Engine
├── Contacts/Calendar Export
├── SMS/Call Log Backup
├── App List Export
├── Restore Wizard
├── Scheduler
└── Security Module
```

## 4. Backup manifest

```json
{
  "backup_id": "2026-05-31_230000_device001",
  "device_id": "device001",
  "device_model": "Xiaomi",
  "android_version": "14",
  "hyperos_version": "unknown",
  "backup_time": "2026-05-31T23:00:00+02:00",
  "items": {
    "photos": true,
    "videos": true,
    "documents": true,
    "contacts": true,
    "calendar": true,
    "sms": false,
    "call_log": false,
    "apps_list": true
  }
}
```

## 5. Серверный Backup API / Server Backup API

```http
POST /api/v1/devices/register
POST /api/v1/backups/create
POST /api/v1/backups/upload
GET  /api/v1/backups/list
GET  /api/v1/backups/{backup_id}
POST /api/v1/restore/plan
```

## 6. Xiaomi/HyperOS

🇷🇺 Для стабильной фоновой синхронизации потребуется инструкция пользователю:
🇬🇧 For stable background sync the user must configure:

- 🇷🇺 разрешить автозапуск / 🇬🇧 allow autostart
- 🇷🇺 снять ограничения батареи / 🇬🇧 remove battery restrictions
- 🇷🇺 разрешить работу в фоне / 🇬🇧 allow background activity
- 🇷🇺 разрешить доступ к файлам/фото / 🇬🇧 allow file/photo access
- 🇷🇺 разрешить SMS/CallLog только при необходимости / 🇬🇧 allow SMS/CallLog only if needed
- 🇷🇺 включить уведомления / 🇬🇧 enable notifications

> 🇷🇺 Подробно: [XIAOMI_MIUI_QUIRKS.md](android/XIAOMI_MIUI_QUIRKS.md)
> 🇬🇧 Details: [XIAOMI_MIUI_QUIRKS.md](android/XIAOMI_MIUI_QUIRKS.md)
