# 10. Безопасность и приватность

## 1. Принципы

1. Закрытая домашняя сеть по умолчанию.
2. Внешний доступ только через VPN.
3. Минимизация прав контейнеров.
4. Секреты вне Git.
5. Персональные данные не отправляются в LLM.
6. Backup обязателен.

## 2. DeepSeek privacy policy

DeepSeek в своей политике указывает, что сервисы не предназначены для обработки sensitive personal data и что пользователь не должен предоставлять такие данные. Поэтому проект запрещает отправлять в DeepSeek семейные фото, контакты, календари, личные документы и полные backup-архивы.

## 3. Сетевые правила

| Сервис | Доступ |
|---|---|
| SSH | LAN/VPN only |
| Samba | LAN only |
| Nextcloud | LAN/VPN only |
| Immich | LAN/VPN only |
| LLM Gateway | LAN only, лучше localhost/internal |
| БД | Docker internal only |

## 4. Hardening

Минимальные меры:

```bash
sudo apt update && sudo apt upgrade -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 192.168.0.0/24 to any port 22 proto tcp
sudo ufw allow from 192.168.0.0/24 to any port 445 proto tcp
sudo ufw enable
```

Правила firewall адаптируются после выбора VPN и reverse proxy.

## 5. Публичный GitHub

Перед публикацией:

```bash
./scripts/security/check_no_secrets.sh
git status --short
```

Запрещено публиковать:

- `.env`;
- реальные IP внешних серверов;
- персональные домены, если они раскрывают личные данные;
- серийные номера HDD;
- API-ключи;
- дампы БД;
- фото и backup-манифесты.
