# 10. Безопасность и приватность / Security & Privacy

## 1. Принципы / Principles

🇷🇺
1. Закрытая домашняя сеть по умолчанию.
2. Внешний доступ только через VPN/SSH tunnel.
3. Минимизация прав контейнеров.
4. Секреты вне Git.
5. Персональные данные не отправляются в LLM.
6. Backup обязателен.

🇬🇧
1. Closed home network by default.
2. External access only via VPN/SSH tunnel.
3. Minimal container privileges.
4. Secrets out of Git.
5. Personal data never sent to external LLMs.
6. Backup is mandatory.

## 2. DeepSeek privacy policy

🇷🇺 DeepSeek в своей политике указывает, что сервисы не предназначены для обработки sensitive personal data. Поэтому проект запрещает отправлять в DeepSeek семейные фото, контакты, календари, личные документы и полные backup-архивы.

🇬🇧 DeepSeek policy states its services are not intended for sensitive personal data. Therefore this project prohibits sending family photos, contacts, calendars, personal documents, or backup archives to DeepSeek.

## 3. Сетевые правила / Network access rules

| Сервис / Service | Доступ / Access |
|---|---|
| SSH | LAN/VPN only |
| Samba | LAN only |
| Nextcloud | LAN/VPN only |
| Immich | LAN/VPN only |
| LLM Gateway | LAN only, preferred localhost/internal |
| БД / Databases | Docker internal only |

## 4. Hardening / Базовая защита

```bash
sudo apt update && sudo apt upgrade -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 192.168.0.0/24 to any port 22 proto tcp
sudo ufw allow from 192.168.0.0/24 to any port 445 proto tcp
sudo ufw enable
```

🇷🇺 Правила firewall адаптируются после выбора VPN и reverse proxy.
🇬🇧 Firewall rules are adapted after choosing VPN and reverse proxy.

## 5. Публичный GitHub / Public GitHub

🇷🇺 Перед публикацией:
🇬🇧 Before publishing:

```bash
./scripts/security/check_no_secrets.sh
git status --short
```

🇷🇺 Запрещено публиковать:
🇬🇧 Never publish:

- `.env` файлы / files
- реальные IP внешних серверов / real IPs of external servers
- персональные домены, если раскрывают личные данные / personal domains revealing personal data
- серийные номера HDD / HDD serial numbers
- API-ключи / API keys
- дампы БД / DB dumps
- фото и backup-манифесты / photos and backup manifests
