# 02. Требования

## 1. Аппаратные требования

| Компонент | Минимум | Рекомендация |
|---|---:|---:|
| SBC | Jetson Nano 4 GB | Jetson Nano 4 GB с радиатором/вентилятором |
| System storage | microSD 64 GB | microSD 128 GB или SSD-boot, если доступен |
| Data storage | USB HDD | USB HDD с отдельным питанием |
| Network | 100 Mbps Ethernet | Gigabit Ethernet |
| Power | стабильное питание Jetson | 5V/4A + отдельное питание HDD |

## 2. Программные требования

| Компонент | Требование |
|---|---|
| ОС | Ubuntu/Linux for Tegra/JetPack compatible Linux |
| Container runtime | Docker Engine |
| Compose | Docker Compose plugin `docker compose` |
| FS HDD | ext4 рекомендуется |
| Reverse proxy | Caddy/Nginx/Nginx Proxy Manager, опционально |
| Backup | restic или borgbackup |
| Monitoring | smartmontools, tegrastats, docker stats |

## 3. Клиентские приложения Android

| Задача | Приложение |
|---|---|
| Файлы | Nextcloud Android |
| Фото/видео | Immich Android |
| Контакты/календарь | DAVx5 |
| Альтернативная синхронизация папок | FolderSync, опционально |

## 4. Требования к безопасности

1. Публичные порты на роутере не открываются на первом этапе.
2. Доступ извне только через VPN/mesh VPN.
3. LLM Gateway не имеет прямого доступа к каталогам фото, контактов и календарей.
4. Все секреты находятся вне Git.
5. Бэкапы проверяются восстановлением.
