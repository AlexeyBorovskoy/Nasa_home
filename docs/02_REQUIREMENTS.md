# 02. Требования / Requirements

## 1. Аппаратные требования / Hardware Requirements

| Компонент / Component | Минимум / Minimum | Рекомендация / Recommended |
|---|---:|---:|
| SBC | Jetson Nano 4 GB | Jetson Nano 4 GB с радиатором / with heatsink+fan |
| System storage | microSD 64 GB | microSD 128 GB or SSD-boot if available |
| Data storage | USB HDD/SSD | USB HDD/SSD с отдельным питанием / with separate power |
| Network | 100 Mbps Ethernet | Gigabit Ethernet |
| Power | стабильное питание / stable Jetson power | 5V/4A + отдельное питание HDD / separate HDD power |

## 2. Программные требования / Software Requirements

| Компонент / Component | Требование / Requirement |
|---|---|
| ОС / OS | Ubuntu/Linux for Tegra/JetPack compatible Linux |
| Container runtime | Docker Engine |
| Compose | Docker Compose plugin `docker compose` |
| FS HDD | ext4 рекомендуется / recommended |
| Reverse proxy | Caddy/Nginx/Nginx Proxy Manager, опционально / optional |
| Backup | restic or borgbackup |
| Monitoring | smartmontools, tegrastats, docker stats |

## 3. Клиентские приложения Android / Android Client Apps

| Задача / Task | Приложение / App |
|---|---|
| Файлы / Files | Nextcloud Android |
| Фото/видео / Photos & video | Immich Android |
| Контакты/календарь / Contacts & calendar | DAVx5 |
| Альтернативная синхронизация / Alternative folder sync | FolderSync, опционально / optional |

## 4. Требования к безопасности / Security Requirements

🇷🇺
1. Публичные порты на роутере не открываются на первом этапе.
2. Доступ извне только через VPN/mesh VPN.
3. LLM Gateway не имеет прямого доступа к каталогам фото, контактов и календарей.
4. Все секреты находятся вне Git.
5. Бэкапы проверяются восстановлением.

🇬🇧
1. No public ports opened on the home router in Stage 1.
2. External access only via VPN/mesh VPN.
3. LLM Gateway has no direct access to photo, contact, or calendar directories.
4. All secrets are outside Git.
5. Backups are verified by restore testing.
