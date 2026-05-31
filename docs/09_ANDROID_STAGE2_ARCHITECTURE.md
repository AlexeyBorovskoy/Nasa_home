# 09. Android Stage 2 Architecture

## 1. Цель Stage 2

Разработать собственное Android-приложение для синхронизации и восстановления пользовательских данных семьи.

Stage 2 не заменяет системный backup Google/Xiaomi полностью, так как Android ограничивает доступ обычных приложений к системным данным.

## 2. Что можно реализовать без root

| Данные | Реализация |
|---|---|
| Фото/видео | Да |
| Документы | Да |
| Downloads | Да |
| Музыка | Да |
| Контакты | Да, через экспорт/vCard или CardDAV |
| Календарь | Да, через iCal/CalDAV |
| SMS | Частично, при разрешениях |
| Журнал вызовов | Частично, при разрешениях |
| Список приложений | Да |
| APK | Частично |
| Данные приложений | Обычно нет |
| Wi-Fi пароли | Нет без системных прав/root |
| Настройки Android | Нет/частично |

## 3. Модули приложения

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

## 5. Серверный Backup API

```http
POST /api/v1/devices/register
POST /api/v1/backups/create
POST /api/v1/backups/upload
GET  /api/v1/backups/list
GET  /api/v1/backups/{backup_id}
POST /api/v1/restore/plan
```

## 6. Xiaomi/HyperOS

Для стабильной фоновой синхронизации потребуется инструкция пользователю:

- разрешить автозапуск;
- снять ограничения батареи;
- разрешить работу в фоне;
- разрешить доступ к файлам/фото;
- разрешить SMS/CallLog только при необходимости;
- включить уведомления.
