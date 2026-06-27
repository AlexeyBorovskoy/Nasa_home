# План продвижения проекта: «Оживим старое железо»

**Проект:** Home Cloud for Old Hardware  
**Рабочая идея:** превращение старого оборудования в домашнее семейное облако  
**Базовый стек:** Nextcloud, Immich, Samba/SFTP, Docker Compose, restic, DeepSeek API Gateway  
**Первичная платформа:** NVIDIA Jetson Nano + USB HDD с отдельным питанием  
**Расширяемые платформы:** Raspberry Pi 4/5, Orange Pi, mini-PC, старые ноутбуки, x86-серверы  
**Цель документа:** сформировать технологию публичного запуска, упаковки и продвижения проекта на GitHub и внешних площадках.

---

## 1. Позиционирование проекта

Главная идея проекта:

```text
Старое железо не на свалку, а в домашнюю инфраструктуру.
```

Рабочее международное позиционирование:

```text
Home Cloud for Old Hardware —
a blueprint for turning old SBCs, mini-PCs, laptops and USB HDDs into a private family cloud.
```

Рабочее русскоязычное позиционирование:

```text
Оживим старое железо:
домашнее облако и фотоархив без Google, Xiaomi Cloud и ежемесячных подписок.
```

Проект не должен позиционироваться как «ещё один docker-compose для Nextcloud». Основная ценность — воспроизводимая инженерная методика: от аппаратного аудита старого устройства до семейного облака, backup/restore и будущей Android-синхронизации.

---

## 2. Продуктовая формула

### 2.1. Английская формула

```text
Home Cloud for Old Hardware is an engineering blueprint for turning unused devices into a private family cloud with files, photos, contacts, calendars, Android sync, backup/restore procedures and privacy-controlled LLM diagnostics.
```

### 2.2. Русская формула

```text
Home Cloud for Old Hardware — инженерный шаблон для превращения старых устройств в частное семейное облако с файлами, фотоархивом, контактами, календарями, Android-синхронизацией, резервным копированием и безопасной LLM-диагностикой.
```

---

## 3. Что должно быть в публичном GitHub

Репозиторий должен выглядеть как инженерный blueprint, а не как личный экспериментальный каталог.

### 3.1. Минимальная структура публичного проекта

```text
home-cloud-old-hardware/
├── README.md
├── QUICK_START.md
├── HARDWARE_COMPATIBILITY.md
├── ARCHITECTURE.md
├── SECURITY.md
├── PRIVACY.md
├── BACKUP_RESTORE.md
├── OLD_HARDWARE_GUIDE.md
├── ANDROID_STAGE2.md
├── LLM_GATEWAY.md
├── docs/
├── docker/
├── scripts/
├── examples/
├── docs/prompts/
└── LICENSE
```

### 3.2. Назначение ключевых документов

| Документ | Назначение |
|---|---|
| `README.md` | Кратко объясняет идею, пользу и сценарии применения |
| `QUICK_START.md` | Пошаговый запуск за 30–60 минут |
| `OLD_HARDWARE_GUIDE.md` | Как выбрать и проверить старое железо |
| `HARDWARE_COMPATIBILITY.md` | Таблица совместимости Jetson Nano, Raspberry Pi, mini-PC, ноутбуков |
| `ARCHITECTURE.md` | Целевая архитектура и связи сервисов |
| `SECURITY.md` | Безопасность, VPN, доступы, hardening |
| `PRIVACY.md` | Что хранится локально, что нельзя отправлять во внешний API |
| `BACKUP_RESTORE.md` | Стратегия резервного копирования и восстановления |
| `ANDROID_STAGE2.md` | Архитектура будущего Android-клиента |
| `LLM_GATEWAY.md` | DeepSeek Gateway, privacy-фильтр, режимы диагностики |
| `docs/references/` | Ссылки на внешнюю документацию |
| `scripts/` | Диагностика, backup, обслуживание |
| `docs/prompts/` | Промты для Codex/агентов |

---

## 4. Главный тезис для README

README должен начинаться не с Docker и не с контейнеров, а с проблемы пользователя.

### 4.1. Английский вариант

```markdown
# Home Cloud for Old Hardware

This project helps turn old hardware into a private family cloud.

Target use cases:
- reuse old Jetson Nano, Raspberry Pi, mini-PC or laptop;
- store family photos and videos locally;
- replace part of Google Drive / Xiaomi Cloud / Google Photos workflow;
- sync Android photos, contacts and calendars;
- keep data under personal control;
- use external LLM API only for diagnostics, not for private media.

Initial target hardware:
- NVIDIA Jetson Nano;
- USB HDD with external power;
- home router;
- Android phones.
```

### 4.2. Русский вариант

```markdown
# Оживим старое железо

Проект предназначен для превращения старого оборудования в домашнее семейное облако.

Цель:
- не выбрасывать старое железо;
- поднять домашний NAS;
- хранить фото и видео семьи локально;
- синхронизировать Android-телефоны;
- использовать Nextcloud для файлов, контактов и календарей;
- использовать Immich для фотоархива;
- подключать DeepSeek API только для технической диагностики.
```

---

## 5. Уникальность проекта

Отдельные компоненты уже существуют: Nextcloud, Immich, Samba, restic, DAVx5, Syncthing, OpenMediaVault. Уникальность проекта не в создании нового файлового сервера, а в сборке, методике и фокусе на старом железе.

| Обычные проекты | Данный проект |
|---|---|
| Просто docker-compose для Nextcloud | Полный путь от старого железа до семейного облака |
| Только фотоархив | Фото + файлы + контакты + календарь + backup |
| Только NAS | NAS + Android-сценарии + будущий restore client |
| Без методики | Пошаговый инженерный runbook |
| Для серверов | Для Jetson Nano, Raspberry Pi, mini-PC, старых ноутбуков |
| Без AI | LLM Gateway для диагностики без отправки личных данных |

Ключевая формула:

```text
Не новый сервис, а воспроизводимая технология оживления старого железа.
```

---

## 6. Целевая аудитория

| Аудитория | Что им важно |
|---|---|
| Домашние пользователи | Сохранить фото, документы, контакты |
| Владельцы старых SBC | Применить Jetson/Raspberry/Orange Pi |
| Linux-энтузиасты | Self-hosted, Docker, NAS |
| Android-пользователи | Альтернатива Google/Xiaomi Cloud |
| Семьи | Семейный архив и восстановление телефонов |
| Разработчики | Архитектура, Codex-ready проект, будущий Android-клиент |
| Privacy-сообщество | Контроль данных, VPN, LLM privacy policy |
| Homelab-сообщество | Практический домашний сервер из имеющегося железа |
| Экологические инициативы | Повторное использование электроники |

---

## 7. Название проекта

### 7.1. Варианты названия

| Название | Оценка |
|---|---|
| `home-cloud-old-hardware` | Максимально ясно |
| `revive-home-cloud` | Хорошее международное |
| `old-hardware-cloud` | Понятное |
| `family-cloud-sbc` | Техническое |
| `jetson-family-cloud` | Слишком узко |
| `revivebox` | Брендовое |
| `oldbox-cloud` | Короткое |
| `homecloud-revival` | Хорошее |

### 7.2. Рекомендуемое название

```text
home-cloud-old-hardware
```

### 7.3. Слоган

Английский:

```text
Revive old hardware into a private family cloud.
```

Русский:

```text
Оживляем старое железо и превращаем его в домашнее семейное облако.
```

---

## 8. Дорожная карта публикации

### 8.1. Этап 1. Подготовить публичный репозиторий

Перед публикацией необходимо:

```text
1. Очистить проект от секретов.
2. Проверить .gitignore.
3. Добавить LICENSE.
4. Добавить README.md.
5. Добавить QUICK_START.md.
6. Добавить схемы архитектуры.
7. Добавить статус проекта: Experimental / Alpha.
8. Добавить SECURITY.md.
9. Добавить CONTRIBUTING.md.
10. Добавить Issue templates.
```

Рекомендуемый статус:

```text
Project status: Alpha / hardware validation stage.
```

### 8.2. Этап 2. Сделать минимально воспроизводимый MVP

MVP должен быть простым:

```text
Jetson Nano / Raspberry Pi / mini-PC
+
USB HDD
+
Docker Compose
+
Nextcloud
+
Immich
+
Samba/SFTP
+
backup scripts
```

Критерий MVP:

```text
Пользователь может взять старое железо, выполнить инструкции и получить рабочее домашнее облако.
```

### 8.3. Этап 3. Опубликовать первый релиз

Первый релиз:

```text
v0.1.0-alpha
```

Состав релиза:

```text
- документация;
- docker-compose templates;
- .env.example;
- scripts/diagnostics;
- scripts/backup;
- hardware audit checklist;
- Jetson Nano guide;
- public roadmap;
- ссылки на внешнюю документацию;
- ограничения проекта.
```

### 8.4. Этап 4. Собрать обратную связь

Нужно включить GitHub Issues templates:

```text
Bug report
Hardware compatibility report
Installation problem
Feature request
Security issue
Documentation improvement
```

Особенно важен шаблон:

```text
Hardware compatibility report
```

Пользователи должны добавлять:

```text
- устройство;
- архитектура CPU;
- RAM;
- диск;
- ОС;
- способ установки;
- результат;
- проблемы;
- логи.
```

Это позволит создать живую базу совместимости.

---

## 9. Как сделать проект заметным

### 9.1. README должен быть визуальным

В README нужны:

```text
1. короткий тезис;
2. схема архитектуры;
3. фото железа;
4. список поддерживаемого оборудования;
5. быстрый старт;
6. предупреждение по backup;
7. roadmap;
8. ссылка на обсуждения.
```

### 9.2. Базовая схема для README

```text
Android Phones
   │
   ├── Nextcloud App ── files/documents
   ├── Immich App ──── photos/videos
   └── DAVx5 ───────── contacts/calendar
          │
          ▼
Old Hardware Server
   ├── Nextcloud
   ├── Immich
   ├── Samba/SFTP
   ├── Backup jobs
   └── DeepSeek Gateway for diagnostics
          │
          ▼
USB HDD / External Storage
```

### 9.3. Реальные фото стенда

Проекту нужны фотографии:

```text
- Jetson Nano;
- USB HDD;
- роутер;
- собранный стенд;
- web-интерфейс Nextcloud;
- web-интерфейс Immich;
- Android autoupload;
- результат backup script.
```

Реальные фото повышают доверие сильнее, чем абстрактные схемы.

### 9.4. Короткое видео

Темы первого видео:

```text
1. Старый Jetson Nano как домашнее облако.
2. Заменяем Google Photos дома.
3. Nextcloud + Immich на старом железе.
4. Семейный архив без подписок.
```

Формат:

```text
5–8 минут
результат в первые 60 секунд
без чрезмерной теории
```

---

## 10. Где продвигать проект

| Площадка | Что публиковать |
|---|---|
| GitHub | Основной репозиторий |
| Habr | Инженерная статья |
| Reddit r/selfhosted | Англоязычная self-hosted аудитория |
| Reddit r/homelab | Старое железо и домашняя инфраструктура |
| Reddit r/DataHoarder | Хранение фото и данных |
| Reddit r/NextCloud | Nextcloud-сценарии |
| Reddit r/Immich | Фотоархив |
| Telegram-каналы Linux/self-hosted | Русскоязычный охват |
| YouTube | Демонстрация проекта |
| Дзен / VC / Habr | Популярная версия |

### 10.1. Заголовок для Habr

```text
Оживляем старое железо: домашнее облако на Jetson Nano, USB HDD, Nextcloud и Immich
```

### 10.2. Заголовок для Reddit

```text
I turned an old Jetson Nano into a private family cloud with Nextcloud, Immich and Android sync
```

---

## 11. Стратегия контента

### 11.1. Серия публикаций

Не рекомендуется публиковать всё одной большой статьёй. Лучше сделать серию.

| Выпуск | Тема |
|---:|---|
| 1 | Почему старое железо ещё полезно |
| 2 | Аппаратный аудит Jetson Nano |
| 3 | Подготовка USB HDD и структуры хранения |
| 4 | Samba/SFTP как базовый NAS |
| 5 | Nextcloud для файлов, контактов и календарей |
| 6 | Immich как домашний Google Photos |
| 7 | Backup/restore без самообмана |
| 8 | DeepSeek Gateway для диагностики, не для личных данных |
| 9 | Android restore client: архитектура второго этапа |
| 10 | Сравнение со старыми ноутбуками, Raspberry Pi и mini-PC |

### 11.2. Главное сообщение каждой публикации

```text
Старое железо может выполнять полезную инфраструктурную роль.
Главное — не перегружать его, а правильно подобрать функции.
```

---

## 12. Что может «взлететь»

### 12.1. Экономика

```text
Семейный архив без ежемесячной подписки.
```

### 12.2. Экология

```text
Не выбрасывать рабочее железо.
```

### 12.3. Контроль данных

```text
Фото, контакты и календарь хранятся дома.
```

### 12.4. Практичность

```text
Старый Jetson/Raspberry/mini-PC получает новую роль.
```

### 12.5. Android/Xiaomi

```text
Резервное копирование семейных Xiaomi-устройств без привязки к Xiaomi Cloud.
```

Эта ниша перспективна, потому что у многих есть Android-телефоны и старое железо, но нет цельной инструкции.

---

## 13. Что может помешать

| Риск | Как обработать |
|---|---|
| Jetson Nano слаб для Immich | Писать честно: ML отключить, стартовать с малого архива |
| Пользователи захотят «одной кнопкой» | Сделать `install.sh`, но после стабилизации инструкции |
| Потеря данных у пользователей | Жёстко писать: это не backup без второго носителя |
| Секреты в репозитории | `.env.example`, secret scan, правила агентов |
| Сложность для новичков | `QUICK_START.md` и пошаговые команды |
| Споры «зачем Jetson, лучше mini-PC» | Поддержать разные классы железа |
| Безопасность внешнего доступа | На первом этапе только VPN, не прямой интернет |
| Перегрев старого железа | Добавить thermal checklist |
| Слабые microSD-карты | Рекомендовать вынос данных на HDD/SSD |
| Разные CPU-архитектуры | Ввести профили ARM64/x86_64 |

---

## 14. Лицензия

### 14.1. Варианты

| Лицензия | Когда использовать |
|---|---|
| MIT | Если нужен максимально простой режим использования |
| Apache-2.0 | Если нужна более формальная защита по патентам |
| GPLv3 | Если нужно требовать открытости производных работ |
| CC BY 4.0 | Для документации, если отделять от кода |

### 14.2. Рекомендация

Для инженерного проекта рекомендуется:

```text
Apache-2.0
```

Причина:

```text
Формальная и распространённая лицензия, подходящая для инфраструктурного open-source проекта.
```

Документацию можно позднее вынести под:

```text
CC BY 4.0
```

На старте допустимо использовать одну лицензию Apache-2.0 для всего репозитория.

---

## 15. GitHub-оформление

### 15.1. Topics

Рекомендуемые GitHub topics:

```text
self-hosted
home-cloud
old-hardware
jetson-nano
raspberry-pi
nextcloud
immich
android-backup
family-cloud
docker-compose
nas
privacy
deepseek
llm-gateway
backup
homelab
```

### 15.2. Описание репозитория

Английское:

```text
Revive old hardware into a private family cloud with Nextcloud, Immich, Android sync and privacy-controlled LLM diagnostics.
```

Русское:

```text
Домашнее семейное облако на старом железе: Nextcloud, Immich, Android-синхронизация и безопасная LLM-диагностика.
```

---

## 16. Технология раскрутки по шагам

### 16.1. Шаг 1. Сделать проект публично понятным

До публикации должны быть готовы:

```text
README.md
QUICK_START.md
ARCHITECTURE.md
OLD_HARDWARE_GUIDE.md
HARDWARE_COMPATIBILITY.md
SECURITY.md
PRIVACY.md
BACKUP_RESTORE.md
```

### 16.2. Шаг 2. Опубликовать GitHub

После публикации:

```text
- добавить topics;
- включить Discussions;
- добавить Issue templates;
- добавить Projects/Roadmap;
- создать release v0.1.0-alpha;
- добавить CHANGELOG.md;
- добавить CONTRIBUTING.md.
```

### 16.3. Шаг 3. Написать первую статью

Тема:

```text
Оживляем старое железо: домашнее облако на Jetson Nano с Nextcloud и Immich
```

Структура статьи:

```text
1. Проблема.
2. Железо.
3. Архитектура.
4. Что получилось.
5. Ограничения.
6. Как повторить.
7. Ссылка на GitHub.
```

### 16.4. Шаг 4. Сделать демонстрационный стенд

Показать:

```text
- вход в Nextcloud;
- загрузку файла;
- контакты/календарь;
- Immich с тестовыми фото;
- Android автозагрузку;
- backup script;
- DeepSeek diagnostic report.
```

### 16.5. Шаг 5. Собрать обратную связь

Запрашивать у пользователей:

```text
- какое старое железо есть;
- что получилось запустить;
- какие ошибки;
- какие устройства добавить в compatibility matrix.
```

### 16.6. Шаг 6. Расширить проект за пределы Jetson

Добавить профили:

```text
profiles/
├── jetson-nano/
├── raspberry-pi-4/
├── raspberry-pi-5/
├── orange-pi/
├── old-laptop/
├── mini-pc/
└── x86-server/
```

Это важно. Проект не должен умереть как частный случай Jetson Nano.

---

## 17. MVP для публичного интереса

### 17.1. Минимальный MVP

```text
1. Аппаратный аудит.
2. Подготовка USB HDD.
3. Samba/SFTP.
4. Docker Compose.
5. Nextcloud.
6. Immich.
7. restic backup.
8. DeepSeek Gateway только для диагностики.
```

### 17.2. Что не включать в MVP

```text
1. Локальную LLM.
2. Сложный Android-клиент.
3. Публичный доступ без VPN.
4. Автоматический one-click installer без тестирования.
5. Machine learning Immich на слабом железе по умолчанию.
```

---

## 18. Публичная матрица совместимости

В проекте нужно создать `HARDWARE_COMPATIBILITY.md`.

Пример таблицы:

| Устройство | CPU/RAM | Storage | Status | Notes |
|---|---|---|---|---|
| Jetson Nano 4GB | ARM64 / 4 GB | USB HDD | Testing | ML in Immich disabled |
| Raspberry Pi 4 4GB | ARM64 / 4 GB | USB SSD | Planned | Good baseline |
| Raspberry Pi 5 8GB | ARM64 / 8 GB | USB SSD | Planned | Better performance |
| Old laptop x86_64 | x86_64 / 8 GB+ | SATA/USB HDD | Planned | Recommended for larger archives |
| Mini-PC x86_64 | x86_64 / 8–16 GB | SSD/HDD | Planned | Best low-power option |

---

## 19. Правила безопасности для публичной версии

В публичной документации обязательно указать:

```text
1. Не открывать SMB/FTP/Nextcloud напрямую в интернет на первом этапе.
2. Использовать VPN для внешнего доступа.
3. Не коммитить .env.
4. Не коммитить DeepSeek API key.
5. Не отправлять личные фото/контакты/календарь в LLM.
6. Делать backup на второй носитель.
7. Проверять восстановление, а не только создание backup.
```

---

## 20. Главный практический вывод

Проект может получить интерес, если не позиционировать его как «ещё одна установка Nextcloud», а подать как:

```text
методику повторного использования старого оборудования
для домашнего облака и семейного цифрового архива.
```

Главный фокус:

```text
Оживим старое железо.
```

Техническое ядро:

```text
Nextcloud + Immich + USB HDD + Docker Compose + Backup + Android sync + DeepSeek diagnostics.
```

Сильная общественная идея:

```text
Старые платы, ноутбуки и mini-PC могут стать полезными домашними серверами, а не электронным мусором.
```

---

## 21. Контрольный чек-лист перед публичной публикацией

```text
[ ] README.md написан простым языком.
[ ] QUICK_START.md проверен на чистой системе.
[ ] В репозитории нет .env и секретов.
[ ] Есть .env.example.
[ ] Есть LICENSE.
[ ] Есть SECURITY.md.
[ ] Есть BACKUP_RESTORE.md.
[ ] Есть OLD_HARDWARE_GUIDE.md.
[ ] Есть HARDWARE_COMPATIBILITY.md.
[ ] Есть Issue templates.
[ ] Есть первый GitHub Release.
[ ] Есть предупреждение: один HDD не является полноценным backup.
[ ] Есть ограничение: Jetson Nano не предназначен для локальной LLM.
[ ] Есть ограничение: Immich ML на слабом железе отключать.
[ ] Есть Roadmap Stage 1 / Stage 2 / Stage 3.
```

---

## 22. Рекомендуемый порядок ближайших действий

```text
1. Переименовать проект в home-cloud-old-hardware или оставить home-cloud-jetson как hardware profile.
2. Обновить README под концепцию «оживим старое железо».
3. Добавить OLD_HARDWARE_GUIDE.md.
4. Добавить HARDWARE_COMPATIBILITY.md.
5. Добавить публичный Roadmap.
6. Подготовить первый аппаратный аудит Jetson Nano.
7. Сделать первый release v0.1.0-alpha.
8. Написать первую статью на Habr.
9. Добавить поддержку профилей Raspberry Pi / mini-PC / old laptop.
```
