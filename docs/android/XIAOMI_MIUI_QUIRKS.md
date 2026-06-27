# Xiaomi MIUI / HyperOS — особенности для самохостинга
# Xiaomi MIUI / HyperOS — Self-hosting Quirks

> 🇷🇺 MIUI (и новый HyperOS) агрессивно управляет фоновыми приложениями для экономии батареи. Без правильных настроек Immich перестанет загружать фото, DAVx⁵ — синхронизировать контакты.
>
> 🇬🇧 MIUI (and the newer HyperOS) aggressively manages background apps to save battery. Without proper settings, Immich will stop uploading photos and DAVx⁵ will stop syncing contacts.

---

## Критически важные настройки / Critical settings (for each app)

### Приложения, которые нужно настроить / Apps to configure

- **Immich** — авто-загрузка фото / auto photo upload
- **DAVx⁵** — синхронизация контактов и календаря / contacts & calendar sync
- **Nextcloud** — синхронизация файлов / file sync
- **Amnezia VPN** — стабильный VPN-туннель / stable VPN tunnel

---

## 1. Снять ограничения батареи / Remove battery restrictions

### Путь / Path (MIUI 14 / HyperOS):

🇷🇺 **Настройки → Приложения → Управление приложениями → [Приложение] → Батарея** → Без ограничений

🇬🇧 **Settings → Apps → Manage apps → [App] → Battery** → No restrictions

> 🇷🇺 На некоторых версиях: Настройки → Батарея → Экономия заряда → [Приложение] → Нет ограничений
> 🇬🇧 On some versions: Settings → Battery → Battery saver → [App] → No restrictions

### Альтернативный путь / Alternative path:

🇷🇺 Зажать иконку приложения → **Сведения о приложении** → **Батарея** → **Без ограничений**
🇬🇧 Long-press the app icon → **App info** → **Battery** → **No restrictions**

---

## 2. Разрешить автозапуск / Allow autostart

### Путь / Path:

🇷🇺 **Настройки → Приложения → Управление приложениями → [Приложение] → Автозапуск** → ✅ Вкл.

🇬🇧 **Settings → Apps → Manage apps → [App] → Autostart** → ✅ On

> 🇷🇺 На HyperOS может называться: **Запуск в фоне** или **Разрешить фоновую активность**
> 🇬🇧 On HyperOS may be called: **Run in background** or **Allow background activity**

---

## 3. Запретить системе завершать приложение / Prevent system from killing the app

### Через настройки разработчика / Via developer settings:

🇷🇺 **Настройки → Дополнительно → Конфиденциальность → Специальные права → Оптимизация батареи**
→ Найти приложение → **Не оптимизировать**

🇬🇧 **Settings → Additional settings → Privacy → Special app access → Battery optimization**
→ Find app → **Don't optimize**

---

## 4. Оставить приложение в памяти / Lock app in RAM (task manager)

🇷🇺
1. Открыть **Менеджер задач** (кнопка квадрат)
2. Найти Immich / DAVx⁵ / Nextcloud
3. Нажать **замок** 🔒 на карточке приложения
4. Теперь «Очистить всё» не закроет это приложение

🇬🇧
1. Open **Task Manager** (square button)
2. Find Immich / DAVx⁵ / Nextcloud
3. Tap the **lock** 🔒 icon on the app card
4. Now "Clear all" will not close this app

---

## 5. Разрешения на уведомления / Notification permissions

🇷🇺 **Настройки → Приложения → [Приложение] → Уведомления** → ✅ Разрешить
DAVx⁵ и Immich показывают уведомление о синхронизации — это нормально и означает, что они работают в фоне.

🇬🇧 **Settings → Apps → [App] → Notifications** → ✅ Allow
DAVx⁵ and Immich show a sync notification — this is normal and confirms they're running in the background.

---

## 6. Immich — специфические настройки / Immich-specific settings

🇷🇺 После разрешения фонового запуска:
1. Immich → **Профиль** → **Резервное копирование**
2. Разрешить:
   - ✅ Заряжается (зарядка)
   - ✅ Wi-Fi (экономия трафика)
   - ⬜ Мобильные данные (по желанию)
3. **Дополнительно → Foreground service** → Включить (держит Immich живым на Xiaomi)

🇬🇧 After allowing background launch:
1. Immich → **Profile** → **Backup**
2. Allow:
   - ✅ While charging
   - ✅ Wi-Fi (saves data)
   - ⬜ Mobile data (optional, if on unlimited plan)
3. **Advanced → Foreground service** → Enable (keeps Immich alive on Xiaomi)

---

## 7. DAVx⁵ — специфические настройки / DAVx⁵-specific settings

🇷🇺
1. DAVx⁵ → Аккаунт → ⚙️ → **Синхронизация в реальном времени** → Нет (экономия батареи)
2. Интервал: **15 минут** (баланс между свежестью и батареей)
3. После каждого добавления контакта/события — нажать **Синхронизировать** вручную или подождать 15 мин

🇬🇧
1. DAVx⁵ → Account → ⚙️ → **Real-time sync** → No (saves battery)
2. Interval: **15 minutes** (balance between freshness and battery)
3. After adding a contact/event — tap **Sync now** or wait 15 min

---

## Таблица настроек по версиям / Settings table by MIUI/HyperOS version

| Настройка / Setting | MIUI 12/13 | MIUI 14 | HyperOS 1/2 |
|---|---|---|---|
| Батарея без ограничений / Battery no restrict | Батарея → Без ограничений | Батарея → Без ограничений | Батарея → Без ограничений |
| Автозапуск / Autostart | Безопасность → Автозапуск | Приложения → Автозапуск | Приложения → Запуск в фоне |
| Блокировка в RAM / Lock in RAM | Менеджер задач → 🔒 | Менеджер задач → 🔒 | Менеджер задач → 🔒 |
| Фоновая активность / Background activity | Батарея → Оптимизация | Конфиденциальность → Оптимизация | Конфиденциальность → Оптимизация |

---

## Проверка работы / Verify it's working

### Проверить, что Immich работает в фоне / Check Immich background upload

🇷🇺
1. Сделать несколько фото
2. Переключиться на другое приложение (НЕ открывать Immich)
3. Подождать 5–10 минут
4. Открыть Immich → проверить что фото загрузились
5. Если нет — посмотреть уведомления: Immich должен показывать «Загрузка...»

🇬🇧
1. Take a few photos
2. Switch to another app (do NOT open Immich)
3. Wait 5–10 minutes
4. Open Immich → verify photos uploaded
5. If not — check notifications: Immich should show "Uploading..."

### Проверить синхронизацию контактов / Check contact sync

🇷🇺
1. Добавить тестовый контакт в Nextcloud Web
2. Подождать до 15 минут
3. Открыть Контакты Xiaomi → контакт должен появиться с аккаунтом «DAVx⁵»

🇬🇧
1. Add a test contact in Nextcloud Web
2. Wait up to 15 minutes
3. Open Xiaomi Contacts → contact should appear with "DAVx⁵" account label

---

## Типичные проблемы / Common problems

### Immich не загружает фото автоматически / Immich doesn't auto-upload

🇷🇺
1. Проверить автозапуск ✅
2. Проверить батарею → Без ограничений ✅
3. Включить **Foreground service** в Immich
4. Заблокировать в RAM через Менеджер задач

🇬🇧
1. Check autostart ✅
2. Check battery → No restrictions ✅
3. Enable **Foreground service** in Immich
4. Lock in RAM via Task Manager

### DAVx⁵ не синхронизирует / DAVx⁵ not syncing

🇷🇺
1. DAVx⁵ → Аккаунт → нажать **Синхронизировать** вручную
2. Если ошибка — проверить URL сервера и пароль
3. Проверить что Nextcloud доступен (открыть браузер, зайти на Nextcloud)

🇬🇧
1. DAVx⁵ → Account → tap **Sync now** manually
2. If error — check server URL and password
3. Verify Nextcloud is reachable (open browser, go to Nextcloud)

### VPN (Amnezia) разрывается в фоне / VPN disconnects in background

🇷🇺 Обязательно:
- Amnezia → Без ограничений батареи
- Amnezia → Автозапуск
- Заблокировать в RAM
Если разрывается при блокировке экрана: Настройки → Дополнительно → Сохранять соединение Wi-Fi в режиме ожидания → **Всегда**

🇬🇧 Required:
- Amnezia → No battery restrictions
- Amnezia → Autostart
- Lock in RAM
If it disconnects on screen lock: Settings → Additional settings → Keep Wi-Fi on during sleep → **Always**

---

## Ссылки / Links

- [ANDROID_SETUP.md](ANDROID_SETUP.md) — общая настройка приложений / general app setup
- [GOOGLE_MIGRATION.md](GOOGLE_MIGRATION.md) — миграция с Google / Google migration
