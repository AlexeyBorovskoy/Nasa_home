# Политика безопасности / Security Policy

## Русская версия

### Сообщение об уязвимостях

Откройте private security advisory на GitHub или свяжитесь с владельцем репозитория напрямую.

### Область применения

Этот проект является инженерным blueprint-шаблоном. Каждый пользователь должен адаптировать его под своё железо, сеть, домены, VPN и модель угроз.

### Чувствительные данные

Нельзя отправлять в репозиторий:

- реальные `.env` файлы;
- API-ключи;
- токены;
- фото и видео;
- дампы баз данных;
- SSH-ключи;
- приватные ключи;
- персональные backup-манифесты;
- логи с персональными данными.

### Privacy для LLM

В Stage 1 DeepSeek API используется только через LLM Gateway и только для обезличенной диагностики, статусов сервисов и проектной документации.

Во внешний LLM нельзя отправлять:

- фото и видео;
- контакты;
- календарь;
- личные документы;
- содержимое backup-архивов;
- ключи, токены и пароли.

## English Version

### Reporting

Open a private security advisory on GitHub or contact the repository owner directly.

### Scope

This project is a blueprint. Users must adapt it to their own hardware, network, domains, VPN, and threat model.

### Sensitive Data

Never submit:

- real `.env` files;
- API keys;
- tokens;
- photos/videos;
- database dumps;
- SSH keys;
- private keys;
- personal backup manifests;
- logs with personal data.

### LLM Privacy

In Stage 1, DeepSeek API is used only through LLM Gateway and only for anonymized diagnostics, service status, and project documentation.

Do not send photos, videos, contacts, calendars, private documents, backup archive contents, keys, tokens, or passwords to an external LLM.
