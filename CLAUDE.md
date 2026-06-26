# CLAUDE.md — NASA Home Cloud

> Этот файл читается Claude Code автоматически при открытии проекта.
> Содержит контекст, команды и правила для работы в этом репозитории.

## Проект

**NASA Home Cloud** — приватный семейный облачный сервер на NVIDIA Jetson Nano 4 GB + USB HDD.
Заменяет Google Photos (→ Immich), Google Drive (→ Nextcloud), облачный NAS (→ Samba).

- GitHub: https://github.com/AlexeyBorovskoy/Nasa_home
- Owner: AlexeyBorovskoy (a.e.borovskoy@gmail.com)
- Текущий релиз: v1.3.5 — Android mobile sync + HTTPS на VPS nginx
- Основная ветка: `main`

## Операционное состояние

**Состояние на 2026-06-26: v1.3.5 — всё работает. USB SSD восстановлен (порт 2). Watchdog активен. Android apps установлены, конфигурация приложений — следующий шаг.**

| Компонент | Статус | Детали |
|---|---|---|
| Jetson Nano | ✅ up | После физического power cycle 2026-06-26 |
| SSD `/dev/sda1` → `/mnt/storage` | ✅ смонтирован | 229G, 217G свободно, rw |
| USB SSD порт | ✅ **порт 2** (1-2.2) | Ранее порт 4 (1-2.4) был неисправен — переткнут |
| SCSI timeout | ✅ **120s confirmed** | `cat /sys/block/sda/device/timeout` = 120 |
| `usbcore.autosuspend=-1` | ✅ **kernel confirmed** | `/sys/module/usbcore/parameters/autosuspend = -1` |
| `usb-storage.quirks=0bda:9210:rw` | ✅ **kernel confirmed** | `/proc/cmdline` содержит quirk |
| USB watchdog systemd timer | ✅ active | `nasa-usb-watchdog.timer` — PORT=2, каждые 3 мин |
| udev watchdog | ✅ active | `/etc/udev/rules.d/85-nasa-storage-watchdog.rules` |
| Docker daemon | ✅ active | 13 контейнеров Up (healthy) |
| Beszel Hub (VPS:8091) | ✅ up | admin@nasa.local / ***REMOVED*** |
| Beszel Agent Jetson (45876) | ✅ up | v0.18.7 |
| Beszel Agent VPS (45877) | ✅ up | v0.18.7 |
| VPS nginx HTTP | ✅ live | :8080 Nextcloud · :2283 Immich · :8090 LLM |
| VPS nginx HTTPS | ✅ live | :8443 Nextcloud · :2443 Immich · :9443 LLM (self-signed 10y) |
| Nextcloud trusted proxy | ✅ configured | via occ: trusted_proxies, overwriteprotocol=https |
| DAVx⁵ endpoint | ✅ live | `https://193.8.215.130:8443/remote.php/dav` → HTTP 401 (корректно) |
| Android apps | ✅ установлены | Immich + Nextcloud из Play Store, DAVx⁵ APK v4.5.14 |
| Android docs | ✅ committed | `docs/android/` — ANDROID_SETUP, GOOGLE_MIGRATION, XIAOMI_MIUI_QUIRKS |

**🔜 Следующий шаг: настройка Android-приложений**
Immich, Nextcloud, DAVx⁵ установлены — нужно настроить URL сервера и авторизоваться.
- Immich: `http://192.168.0.50:2283` (дома) / `https://193.8.215.130:2443` (вне сети)
- Nextcloud: `https://193.8.215.130:8443`
- DAVx⁵: `https://193.8.215.130:8443/remote.php/dav`

## Железо и доступ

| Компонент | Адрес / Путь | Примечание |
|---|---|---|
| Jetson Nano | `192.168.0.50` | LAN, статический IP |
| SSH на Jetson | `ssh admin@192.168.0.50` | key-based, из Git Bash |
| SSH через VPS | `ssh root@193.8.215.130` → `ssh -p 10022 admin@127.0.0.1` | текущий рабочий путь из внешней сети |
| sudo на Jetson | `sudo -S <cmd>` | пароль брать только из приватного runtime/local secret storage; не коммитить |
| VPS (Vienna) | `193.8.215.130` | `ssh -i ~/.ssh/borovskoy_new_ed25519 root@193.8.215.130` |
| Репо на Jetson | `~/nasa` | `/home/admin/nasa` |

## GitHub CLI (gh)

**Установлен:** `C:\tools\gh\bin\gh.exe` (также в PATH → работает как `gh` из Git Bash и PowerShell)  
**Авторизован:** keyring (Windows), токен с полными правами `repo` + `admin`

```bash
# Из Git Bash (рекомендуется):
gh repo view                          # инфо о репозитории
gh issue list                        # список issues
gh issue create --title "..." --body "..."
gh pr list                           # список PR
gh pr create --title "..." --body "..."
gh release list                      # список релизов
gh release create v1.x.x --notes "..."
gh api repos/AlexeyBorovskoy/Nasa_home/topics  # topics

# Из PowerShell (полный путь или просто gh если PATH обновлён):
& "C:\tools\gh\bin\gh.exe" issue list
```

**Если `gh` разлогинился:**
```bash
# Получить токен из git credential manager:
printf 'protocol=https\nhost=github.com\n' | git credential fill | grep password
# Авторизовать:
echo "ghp_TOKEN" | gh auth login --with-token
```

## Частые операции

### Коммит и пуш (из Windows, рабочая директория репо)
```bash
cd "e:/Linux mint/virtual_VM/shared/NASA"
git add <files>
git commit -m "тип: описание\n\nCo-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
git push
```

### SSH-команда на Jetson
```bash
ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no admin@192.168.0.50 "команда"
```

### Git pull на Jetson
```bash
ssh admin@192.168.0.50 "cd ~/nasa && git pull --ff-only"
```

### Docker Compose на Jetson
```bash
ssh admin@192.168.0.50 "cd ~/nasa && docker compose -f docker/compose/docker-compose.monitoring.yml --env-file config/.env up -d"
```

### Создать GitHub issue
```bash
gh issue create \
  --title "Заголовок" \
  --body "Описание" \
  --label "enhancement"
```

### Создать release
```bash
git tag -a v1.x.x -m "описание"
git push origin v1.x.x
gh release create v1.x.x --title "v1.x.x — название" --notes "описание"
```

## Структура проекта

```
docker/compose/   — Docker Compose файлы для всех сервисов
config/.env       — реальные секреты (НЕ в git, .gitignore)
config/.env.example — шаблон (в git)
scripts/          — bash/python скрипты (backup, monitoring, setup)
systemd/          — systemd units (таймеры, сервисы)
docs/             — документация (00–22)
tests/goss/       — goss infrastructure tests
prompts/          — агентные промпты (CODEX_*)
```

## Сервисы и порты (Jetson 192.168.0.50)

| Сервис | Порт | URL |
|---|---|---|
| Nextcloud | 8080 | http://192.168.0.50:8080 · live after controlled start |
| Immich | 2283 | http://192.168.0.50:2283 |
| LLM Gateway | 8090 | http://192.168.0.50:8090 |
| nasa-api + Swagger | 8099 | http://192.168.0.50:8099/docs |
| Netdata | 19999 | http://192.168.0.50:19999 |
| Uptime Kuma | 3001 | http://192.168.0.50:3001 |
| Portainer | 9000 | http://192.168.0.50:9000 |
| Beszel Agent | 45876 | внутренний (→ Hub через tunnel) |

VPS (193.8.215.130): Nextcloud :8080, Immich :2283, LLM Gateway :8090
**Beszel Hub: http://193.8.215.130:8091** (login: admin@nasa.local / ***REMOVED***)
После подключения SSD → добавить Jetson в Beszel: Host = `127.0.0.1:45876`

## Жёсткие правила

1. **НЕ коммитить** реальные `.env`, пароли, токены, ключи, персональные данные.
2. **НЕ трогать** Amnezia VPN контейнеры на VPS — уронит ~25 VPN клиентов.
3. **НЕ удалять** сетевой профиль `nasa-lan` на Jetson (eth0, 192.168.0.50/24).
4. **НЕ открывать** сервисы напрямую в интернет без отдельного решения.
5. **Destructive команды** (rm -rf, форматирование, DROP DATABASE) — только с явного подтверждения.
6. Перед push: `./scripts/security/check_no_secrets.sh`

## Workflow (стандартная процедура)

1. Изменения в файлах проекта (Windows)
2. `git add` + `git commit` (с Co-Authored-By)
3. `git push`
4. `ssh admin@192.168.0.50 "cd ~/nasa && git pull --ff-only"` или через VPS `ssh root@193.8.215.130 "ssh -p 10022 admin@127.0.0.1 'cd ~/nasa && git pull --ff-only'"` (если нужно применить на Jetson)
5. Перед запуском Nextcloud/Immich/backup: `sudo bash scripts/storage/storage_preflight.sh`
6. Перезапуск затронутых контейнеров (если compose-файлы изменились и preflight прошёл)
7. После крупных изменений: `git tag` + `gh release create`
8. Обновить README и CHANGELOG

## Память

Память о проекте (cross-session): `C:\Users\Alexey\.claude\projects\e--Linux-mint-virtual-VM-shared-NASA\memory\`  
Индекс: `MEMORY.md` в той же папке.
