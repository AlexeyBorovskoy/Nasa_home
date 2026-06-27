# Подробный план и содержание работ по продвижению проекта на GitHub

**Проект:** Home Cloud for Old Hardware  
**Рабочий слоган:** «Оживим старое железо»  
**Техническое ядро:** Nextcloud + Immich + Samba/SFTP + Docker Compose + Backup + DeepSeek Gateway  
**Первичная аппаратная цель:** NVIDIA Jetson Nano + USB HDD с отдельным питанием  
**Расширяемые цели:** Raspberry Pi, Orange Pi, mini-PC, старые ноутбуки, x86-серверы  
**Назначение документа:** определить полный план работ по упаковке, публикации, продвижению и развитию проекта на GitHub.

---

## 1. Цель продвижения

Цель продвижения — не просто выложить репозиторий, а сформировать вокруг проекта понятную инженерную концепцию:

```text
старое железо → домашнее облако → семейный архив → Android-синхронизация → backup/restore → контролируемая AI-диагностика
```

Проект должен восприниматься как воспроизводимый набор методик, конфигураций и документации для превращения старого оборудования в полезную домашнюю инфраструктуру.

---

## 2. Ключевое позиционирование

### 2.1. Основная формулировка

```text
Home Cloud for Old Hardware — инженерный проект по превращению старого оборудования в частное семейное облако с файлами, фотоархивом, контактами, календарями, Android-синхронизацией, резервным копированием и безопасной LLM-диагностикой.
```

### 2.2. Короткое описание для GitHub

```text
Revive old hardware into a private family cloud with Nextcloud, Immich, Android sync, backup/restore and privacy-controlled DeepSeek diagnostics.
```

### 2.3. Русскоязычное описание

```text
Домашнее семейное облако на старом железе: Nextcloud, Immich, Android-синхронизация, резервное копирование и безопасная диагностика через DeepSeek API.
```

### 2.4. Главная идея

```text
Старое железо не на свалку, а в домашнюю инфраструктуру.
```

---

## 3. Целевые аудитории

| № | Аудитория | Основная боль | Что показывать |
|---:|---|---|---|
| 1 | Владельцы старых SBC | Плата лежит без дела | Jetson/Raspberry как домашний сервер |
| 2 | Домашние пользователи | Фото, документы и контакты завязаны на облака | Локальное семейное облако |
| 3 | Android/Xiaomi-пользователи | Зависимость от Google/Xiaomi Cloud | Свой центр синхронизации и восстановления |
| 4 | Linux/self-hosted сообщество | Нужен воспроизводимый стек | Docker Compose, scripts, runbook |
| 5 | Homelab-сообщество | Нужен практический проект для дома | NAS + cloud + photo archive |
| 6 | Privacy-сообщество | Риск утечки личных данных | Privacy policy и LLM-фильтр |
| 7 | Разработчики | Нужна хорошая архитектура под развитие | Codex-ready структура, prompts, roadmap |
| 8 | Экологические инициативы | Электронные отходы | Повторное использование оборудования |

---

## 4. Продуктовая упаковка проекта

### 4.1. Что проект должен обещать

Проект должен обещать реалистичный результат:

```text
1. Поднять домашнее облако на старом железе.
2. Хранить семейные фото, видео и документы локально.
3. Синхронизировать Android-фото, контакты и календари.
4. Иметь базовую стратегию backup/restore.
5. Получить диагностического AI-помощника без отправки личных данных.
```

### 4.2. Что проект не должен обещать

Необходимо явно ограничить ожидания:

```text
1. Это не полная замена Google/Xiaomi Cloud на уровне системного backup Android.
2. Один USB HDD не является полноценным backup.
3. Jetson Nano не предназначен для локальной LLM.
4. Immich ML на слабом железе должен быть ограничен или отключён.
5. Публичный доступ в интернет без VPN не является безопасным режимом первого этапа.
```

---

## 5. Структура публичного репозитория

Рекомендуемая структура:

```text
home-cloud-old-hardware/
├── README.md
├── QUICK_START.md
├── PROJECT_STATUS.md
├── ROADMAP.md
├── CHANGELOG.md
├── LICENSE
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── PRIVACY.md
├── SECRETS_POLICY.md
├── BACKUP_RESTORE.md
├── OLD_HARDWARE_GUIDE.md
├── HARDWARE_COMPATIBILITY.md
├── ARCHITECTURE.md
├── ANDROID_STAGE2.md
├── LLM_GATEWAY.md
│
├── docs/
│   ├── references/
│   ├── architecture/
│   ├── deployment/
│   ├── security/
│   ├── operations/
│   ├── promotion/
│   └── hardware/
│
├── docker/
│   ├── compose/
│   ├── env-templates/
│   └── profiles/
│
├── scripts/
│   ├── diagnostics/
│   ├── backup/
│   ├── maintenance/
│   └── fetch_external_docs.sh
│
├── services/
│   ├── llm-gateway/
│   └── backup-api/
│
├── profiles/
│   ├── jetson-nano/
│   ├── raspberry-pi-4/
│   ├── raspberry-pi-5/
│   ├── orange-pi/
│   ├── old-laptop/
│   ├── mini-pc/
│   └── x86-server/
│
├── docs/prompts/
│   ├── CODEX_PROJECT_BOOTSTRAP_PROMPT.md
│   ├── CODEX_JETSON_AUDIT_PROMPT.md
│   ├── CODEX_SECURITY_AUDIT_PROMPT.md
│   ├── CODEX_DEPLOYMENT_PROMPT.md
│   └── CODEX_ANDROID_STAGE2_PROMPT.md
│
├── examples/
│   ├── hardware-audit-report.example.md
│   ├── backup-report.example.md
│   └── diagnostic-report.example.md
│
└── .github/
    ├── ISSUE_TEMPLATE/
    ├── workflows/
    ├── pull_request_template.md
    └── dependabot.yml
```

---

## 6. Документы первого публичного релиза

### 6.1. Обязательные документы

| Документ | Содержание | Приоритет |
|---|---|---:|
| `README.md` | Суть проекта, схема, быстрый старт, ограничения | 1 |
| `QUICK_START.md` | Минимальный запуск | 1 |
| `OLD_HARDWARE_GUIDE.md` | Как выбрать старое железо | 1 |
| `HARDWARE_COMPATIBILITY.md` | Таблица совместимости | 1 |
| `ARCHITECTURE.md` | Архитектура системы | 1 |
| `SECURITY.md` | Безопасность доступа | 1 |
| `PRIVACY.md` | Защита персональных данных | 1 |
| `BACKUP_RESTORE.md` | Backup/restore | 1 |
| `PROJECT_STATUS.md` | Статус Alpha, ограничения | 1 |
| `ROADMAP.md` | Stage 1 / Stage 2 / Stage 3 | 1 |
| `CONTRIBUTING.md` | Как участвовать | 2 |
| `CODE_OF_CONDUCT.md` | Правила сообщества | 2 |
| `CHANGELOG.md` | История изменений | 2 |

### 6.2. Технические документы

| Документ | Содержание |
|---|---|
| `docs/deployment/JETSON_NANO_DEPLOYMENT.md` | Установка на Jetson Nano |
| `docs/deployment/DOCKER_COMPOSE_DEPLOYMENT.md` | Docker Compose deployment |
| `docs/hardware/HARDWARE_AUDIT.md` | Проверка железа |
| `docs/security/LLM_PRIVACY_POLICY.md` | Политика работы с DeepSeek API |
| `docs/operations/RUNBOOK.md` | Операционные процедуры |
| `docs/operations/TROUBLESHOOTING.md` | Диагностика типовых проблем |
| `docs/references/REFERENCE_LINKS.md` | Ссылки на документацию |

---

## 7. README: обязательное содержание

README должен быть главным продающим и техническим документом.

### 7.1. Структура README

```markdown
# Home Cloud for Old Hardware

## 1. What is this project?
## 2. Why old hardware?
## 3. Target use cases
## 4. Architecture
## 5. Supported hardware
## 6. Stage 1 stack
## 7. Quick start
## 8. Security and privacy model
## 9. Backup warning
## 10. Project roadmap
## 11. Screenshots / demo
## 12. Contributing
## 13. License
```

### 7.2. Блок «Why»

```text
Many old SBCs, mini-PCs and laptops are still powerful enough for useful home infrastructure. This project provides a reproducible blueprint to turn them into a private family cloud instead of electronic waste.
```

### 7.3. Блок «What you get»

```text
- private file cloud with Nextcloud;
- contacts and calendar sync;
- photo/video archive with Immich;
- local NAS access with Samba/SFTP;
- backup and restore procedures;
- DeepSeek-based diagnostic assistant;
- roadmap for future Android restore client.
```

### 7.4. Блок предупреждений

```text
Important limitations:
- one HDD is not a backup;
- do not expose SMB/FTP directly to the Internet;
- local LLM is not part of Stage 1;
- Immich ML should be disabled on weak hardware;
- personal media must not be sent to external LLM APIs.
```

---

## 8. QUICK_START: содержание

Цель `QUICK_START.md` — дать пользователю минимальный путь к результату.

### 8.1. Структура

```markdown
# Quick Start

## 1. Requirements
## 2. Prepare storage
## 3. Run hardware audit
## 4. Install Docker
## 5. Configure environment
## 6. Start base services
## 7. Validate Nextcloud
## 8. Validate Immich
## 9. Configure Android apps
## 10. Configure backup
## 11. Troubleshooting
```

### 8.2. MVP-команды

MVP-команды должны быть короткими и проверяемыми:

```bash
./scripts/diagnostics/hardware_audit.sh
cp config/.env.example config/.env
nano config/.env
docker compose -f docker/compose/stage1.yml config
docker compose -f docker/compose/stage1.yml up -d
docker compose -f docker/compose/stage1.yml ps
```

---

## 9. GitHub Issues: шаблоны

Необходимо подготовить `.github/ISSUE_TEMPLATE/`.

### 9.1. `bug_report.yml`

Содержит:

```text
- description;
- expected behavior;
- actual behavior;
- logs;
- docker compose version;
- hardware profile;
- operating system;
- steps to reproduce.
```

### 9.2. `hardware_compatibility_report.yml`

Содержит:

```text
- device model;
- CPU architecture;
- RAM;
- storage type;
- OS version;
- Docker version;
- services tested;
- result;
- notes;
- logs.
```

### 9.3. `installation_problem.yml`

Содержит:

```text
- installation step;
- command used;
- error output;
- hardware profile;
- network setup;
- storage mount point.
```

### 9.4. `feature_request.yml`

Содержит:

```text
- use case;
- proposed feature;
- target hardware;
- priority;
- alternatives considered.
```

### 9.5. `security_report.md`

Для security issue лучше направлять пользователя к `SECURITY.md` и не просить публиковать уязвимости публично.

---

## 10. GitHub Discussions

Рекомендуется включить Discussions и создать категории:

| Категория | Назначение |
|---|---|
| Announcements | Релизы и новости |
| General | Общие вопросы |
| Hardware Builds | Отчёты по железу |
| Installation Help | Помощь с установкой |
| Android Sync | Вопросы Android-синхронизации |
| Backup/Restore | Вопросы backup/restore |
| Ideas | Идеи развития |
| Showcase | Фото и отчёты пользовательских стендов |

---

## 11. GitHub Projects / Roadmap

Рекомендуется создать GitHub Project с колонками:

```text
Backlog
Ready
In Progress
Review
Done
Blocked
```

### 11.1. Milestones

| Milestone | Цель |
|---|---|
| `v0.1.0-alpha` | Публичная документация и Jetson Nano MVP |
| `v0.2.0` | Стабильный Stage 1 Docker Compose |
| `v0.3.0` | Raspberry Pi / mini-PC profiles |
| `v0.4.0` | Backup/restore validation |
| `v0.5.0` | DeepSeek Gateway MVP |
| `v1.0.0` | Стабильный self-hosted blueprint |
| `v2.0.0` | Android Stage 2 client |

### 11.2. Labels

Рекомендуемые labels:

```text
area:docs
area:docker
area:hardware
area:security
area:backup
area:android
area:llm
area:nextcloud
area:immich
area:nas
priority:low
priority:medium
priority:high
status:blocked
status:needs-info
good-first-issue
help-wanted
```

---

## 12. GitHub Actions

Для публичного проекта полезны проверки без развёртывания реального сервера.

### 12.1. Минимальный набор workflow

| Workflow | Назначение |
|---|---|
| `markdown-lint.yml` | Проверка Markdown |
| `shellcheck.yml` | Проверка shell-скриптов |
| `docker-compose-config.yml` | Проверка валидности compose-файлов |
| `secret-scan.yml` | Поиск случайно закоммиченных секретов |
| `links-check.yml` | Проверка ссылок в документации |

### 12.2. Что не делать на первом этапе

```text
1. Не запускать тяжёлые контейнеры в CI.
2. Не тестировать реальный Immich/Nextcloud в GitHub Actions без необходимости.
3. Не хранить секреты DeepSeek в GitHub Actions на раннем этапе.
4. Не делать автоматический deploy из публичного репозитория.
```

---

## 13. Release-стратегия

### 13.1. Первый релиз

```text
v0.1.0-alpha
```

Состав:

```text
- README.md;
- QUICK_START.md;
- ARCHITECTURE.md;
- OLD_HARDWARE_GUIDE.md;
- HARDWARE_COMPATIBILITY.md;
- SECURITY.md;
- PRIVACY.md;
- BACKUP_RESTORE.md;
- docker compose templates;
- .env.example;
- diagnostic scripts;
- backup scripts;
- Codex prompts.
```

### 13.2. Release notes

Шаблон release notes:

```markdown
# v0.1.0-alpha

## Added
- Initial public documentation.
- Jetson Nano hardware profile.
- Stage 1 architecture.
- Nextcloud + Immich deployment templates.
- DeepSeek Gateway design.
- Backup/restore plan.

## Known limitations
- Not yet tested on multiple hardware profiles.
- Immich ML is disabled by default on weak hardware.
- Android restore client is planned for Stage 2.
- No one-click installer yet.

## Safety notes
- Do not expose services directly to the Internet.
- Use VPN for remote access.
- One HDD is not a backup.
```

---

## 14. Контент-план продвижения

### 14.1. Серия публикаций

| № | Тема | Цель |
|---:|---|---|
| 1 | Оживляем старое железо | Объяснить идею |
| 2 | Аппаратный аудит Jetson Nano | Показать инженерный подход |
| 3 | USB HDD и структура хранения | Объяснить storage layer |
| 4 | Samba/SFTP как базовый NAS | Быстрый практический результат |
| 5 | Nextcloud для файлов, контактов, календарей | Основной cloud layer |
| 6 | Immich как домашний Google Photos | Фото/видео сценарий |
| 7 | Backup без самообмана | Защита от потери данных |
| 8 | DeepSeek Gateway | AI-диагностика без отправки личных данных |
| 9 | Android Stage 2 | Будущий restore client |
| 10 | Сравнение Jetson, Raspberry Pi, mini-PC | Масштабирование аудитории |

### 14.2. Habr-статья №1

Заголовок:

```text
Оживляем старое железо: домашнее облако на Jetson Nano, USB HDD, Nextcloud и Immich
```

Структура:

```text
1. Почему возникла задача.
2. Какое железо использовано.
3. Почему не локальная LLM.
4. Почему Nextcloud + Immich.
5. Архитектура.
6. Первый MVP.
7. Ограничения Jetson Nano.
8. Что дальше.
9. Ссылка на GitHub.
```

### 14.3. Reddit-пост

Заголовок:

```text
I turned an old Jetson Nano into a private family cloud with Nextcloud, Immich and Android sync
```

Краткая структура:

```text
- Hardware used.
- Services deployed.
- What works.
- What is limited.
- Why old hardware.
- GitHub link.
- Ask for hardware compatibility reports.
```

---

## 15. Демонстрационные материалы

### 15.1. Скриншоты

Нужны:

```text
1. Фото старого железа до сборки.
2. Фото собранного стенда.
3. Nextcloud dashboard.
4. Nextcloud files.
5. Nextcloud contacts/calendar.
6. Immich web gallery.
7. Android Immich upload.
8. Docker compose status.
9. Backup report.
10. DeepSeek diagnostic report.
```

### 15.2. Видео

Первое видео:

```text
Тема: Старый Jetson Nano как домашнее облако
Длина: 5–8 минут
Формат: проблема → железо → запуск → результат → ограничения → GitHub
```

### 15.3. Архитектурные схемы

Минимум три схемы:

```text
1. High-level architecture.
2. Data flow: Android → Nextcloud/Immich → HDD.
3. Backup/restore flow.
```

---

## 16. Метрики успеха

### 16.1. GitHub-метрики

| Метрика | Цель на 1 месяц | Цель на 3 месяца |
|---|---:|---:|
| Stars | 50–100 | 300+ |
| Forks | 5–10 | 30+ |
| Issues | 10+ | 50+ |
| Hardware reports | 5+ | 25+ |
| Contributors | 1–3 | 5+ |
| Discussions | 5+ | 30+ |

### 16.2. Контент-метрики

| Метрика | Цель |
|---|---:|
| Habr views | 5 000+ |
| Reddit upvotes | 100+ |
| GitHub visits после публикации | 500+ |
| Комментарии с железом пользователей | 20+ |

---

## 17. Работа с сообществом

### 17.1. Что просить у пользователей

```text
1. Присылайте отчёты по вашему старому железу.
2. Проверяйте инструкции на Raspberry Pi / mini-PC / old laptop.
3. Добавляйте hardware compatibility reports.
4. Предлагайте улучшения backup/restore.
5. Не присылайте личные данные и реальные секреты в issues.
```

### 17.2. Как отвечать на issues

Стиль ответов:

```text
1. Запросить hardware profile.
2. Запросить минимальный лог без секретов.
3. Уточнить шаг инструкции.
4. Предложить воспроизводимую проверку.
5. Зафиксировать результат в troubleshooting.
```

### 17.3. Как использовать вклад пользователей

```text
1. Все успешные стенды добавлять в HARDWARE_COMPATIBILITY.md.
2. Частые ошибки переносить в TROUBLESHOOTING.md.
3. Хорошие идеи переносить в ROADMAP.md.
4. Повторяемые вопросы переносить в FAQ.md.
```

---

## 18. Расширение проекта за пределы Jetson Nano

### 18.1. Почему это важно

Если проект останется только про Jetson Nano, аудитория будет узкой. Нужно позиционировать Jetson Nano как первый hardware profile, а не единственную цель.

### 18.2. Hardware profiles

```text
profiles/
├── jetson-nano/
│   ├── README.md
│   ├── limitations.md
│   └── compose.override.yml
├── raspberry-pi-4/
├── raspberry-pi-5/
├── orange-pi/
├── old-laptop/
├── mini-pc/
└── x86-server/
```

### 18.3. Матрица профилей

| Профиль | Статус | Особенности |
|---|---|---|
| Jetson Nano | Primary | 4 GB RAM, отключать тяжёлый ML |
| Raspberry Pi 4 | Planned | Популярная SBC-платформа |
| Raspberry Pi 5 | Planned | Лучше для Immich |
| Orange Pi | Planned | Дешёвые ARM-варианты |
| Old laptop | Planned | Хорошая производительность, больше места |
| Mini-PC | Recommended | Лучший баланс мощности и энергопотребления |
| x86-server | Advanced | Для больших архивов |

---

## 19. DeepSeek Gateway как отдельная ценность

### 19.1. Позиционирование

DeepSeek Gateway не должен быть «игрушкой». Его надо подать как безопасный диагностический слой:

```text
LLM assists with diagnostics, logs and documentation, but personal photos, contacts, calendars and private documents are not sent to the external API by default.
```

### 19.2. Сценарии

```text
1. Объяснить ошибку Docker Compose.
2. Сформировать диагностический отчёт.
3. Помочь восстановить сервис после сбоя.
4. Проверить backup status.
5. Объяснить пользователю, что делать дальше.
```

### 19.3. Ограничения

```text
1. Не отправлять фото.
2. Не отправлять контакты.
3. Не отправлять календарь.
4. Не отправлять личные документы.
5. Не отправлять ключи, токены, .env.
```

---

## 20. Риски продвижения

| Риск | Вероятность | Влияние | Меры |
|---|---:|---:|---|
| Проект воспримут как очередной compose-файл | Средняя | Высокое | Усилить методику и old hardware focus |
| Пользователи потеряют данные | Низкая/средняя | Критическое | Жёсткие backup warnings |
| Jetson Nano окажется слабым | Высокая | Среднее | Поддержать mini-PC и Raspberry Pi |
| Issues будут без логов | Высокая | Среднее | Issue templates |
| Утечка секретов от пользователей | Средняя | Высокое | Security policy и redaction guide |
| Слишком сложный старт | Средняя | Высокое | QUICK_START и минимальный MVP |
| Споры по LLM/privacy | Средняя | Среднее | Чёткая LLM privacy policy |

---

## 21. План работ по неделям

### Неделя 1. Подготовка публичного репозитория

```text
[ ] Выбрать финальное название.
[ ] Очистить структуру проекта.
[ ] Подготовить README.md.
[ ] Подготовить QUICK_START.md.
[ ] Подготовить ARCHITECTURE.md.
[ ] Подготовить SECURITY.md.
[ ] Подготовить PRIVACY.md.
[ ] Подготовить BACKUP_RESTORE.md.
[ ] Добавить LICENSE.
[ ] Добавить .gitignore.
```

### Неделя 2. Техническая воспроизводимость

```text
[ ] Проверить hardware audit script.
[ ] Проверить storage preparation guide.
[ ] Проверить Docker installation guide.
[ ] Проверить stage1 compose config.
[ ] Проверить .env.example.
[ ] Проверить Nextcloud deployment.
[ ] Проверить Immich deployment.
[ ] Проверить backup script.
```

### Неделя 3. GitHub-оформление

```text
[ ] Добавить topics.
[ ] Добавить issue templates.
[ ] Добавить pull request template.
[ ] Добавить GitHub Discussions.
[ ] Добавить GitHub Project/Roadmap.
[ ] Добавить labels.
[ ] Добавить first release draft.
[ ] Добавить CHANGELOG.md.
```

### Неделя 4. Публичный запуск

```text
[ ] Создать release v0.1.0-alpha.
[ ] Опубликовать Habr-статью.
[ ] Опубликовать Reddit-пост.
[ ] Опубликовать Telegram-анонс.
[ ] Собрать первые hardware reports.
[ ] Обновить FAQ/TROUBLESHOOTING.
```

---

## 22. Контрольный чек-лист перед публикацией

```text
[ ] В репозитории нет .env.
[ ] В репозитории нет DeepSeek API key.
[ ] В репозитории нет личных фото/видео.
[ ] README объясняет идею за 30 секунд.
[ ] QUICK_START можно выполнить последовательно.
[ ] Есть предупреждение: один HDD не backup.
[ ] Есть предупреждение: не открывать сервисы напрямую в интернет.
[ ] Есть Jetson Nano limitations.
[ ] Есть hardware compatibility matrix.
[ ] Есть ROADMAP.
[ ] Есть LICENSE.
[ ] Есть SECURITY.md.
[ ] Есть Issue templates.
[ ] Есть release v0.1.0-alpha.
[ ] Есть хотя бы одна архитектурная схема.
[ ] Есть фото или план фото стенда.
```

---

## 23. Итоговая стратегия

Проект следует продвигать не как техническую сборку контейнеров, а как общественно и practically полезную методику:

```text
Оживить старое железо.
Сохранить семейные данные локально.
Снизить зависимость от коммерческих облаков.
Сделать понятный open-source blueprint для повторения.
```

Технический фокус первого публичного релиза:

```text
Jetson Nano + USB HDD + Nextcloud + Immich + Samba/SFTP + restic + DeepSeek diagnostics.
```

Продуктовый фокус:

```text
Private family cloud from old hardware.
```

GitHub-фокус:

```text
Documentation-first, reproducible, safe, extensible, community-driven.
```
