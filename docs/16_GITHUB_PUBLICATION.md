# 16. Публикация на GitHub

## 1. Да, проект можно публиковать

Проект не содержит закрытых компонентов и построен на open-source/self-hosted решениях. Он может быть опубликован как инженерный шаблон.

## 2. Рекомендуемое имя репозитория

Варианты:

```text
home-cloud-jetson
family-cloud-jetson
selfhosted-family-cloud
jetson-family-cloud-blueprint
homecloud-arm-blueprint
```

Наиболее универсальное имя:

```text
selfhosted-family-cloud
```

Потому что проект позже можно расширить за пределы Jetson Nano.

## 3. Позиционирование

```text
A Codex-ready self-hosted family cloud blueprint for ARM/SBC devices:
Nextcloud + Immich + Android backup roadmap + privacy-controlled DeepSeek LLM gateway.
```

## 4. Что даст шанс на рост

| Фактор | Почему важно |
|---|---|
| Поддержка разных устройств | Jetson Nano слишком узкая аудитория |
| Пошаговые install scripts | Пользователи не любят ручную сборку |
| Реальные тесты | Повышают доверие |
| Скриншоты | Упрощают понимание |
| Xiaomi/Android инструкции | Конкретная практическая боль |
| LLM Gateway с privacy policy | Отличие от обычных docker-compose проектов |
| Codex-ready prompts | Новый формат документации для агентной разработки |

## 5. Что убрать перед публикацией

- реальные IP;
- серийные номера;
- семейные имена;
- фото оборудования с серийниками, если они раскрывают личные данные;
- реальные токены;
- личные домены;
- dumps/logs.

## 6. Минимальный pre-release checklist

```bash
./scripts/security/check_no_secrets.sh
shellcheck scripts/**/*.sh || true
docker compose -f docker/compose/docker-compose.stage1.yml config
find . -name '.env' -o -name '*.key' -o -name '*.pem'
```

## 7. GitHub labels

```text
stage-1
stage-2-android
security
backup
documentation
jetson
raspberry-pi
nextcloud
immich
deepseek
help-wanted
good-first-issue
```

## 8. Roadmap для публичного README

- v0.1: документация и шаблоны;
- v0.2: аппаратный аудит и storage scripts;
- v0.3: Nextcloud compose;
- v0.4: Immich compose;
- v0.5: backup/restore;
- v0.6: LLM Gateway;
- v0.7: Android Stage 2 API draft;
- v1.0: проверенная установка на Jetson Nano/Raspberry Pi/mini-PC.

---

## 9. Что уже реализовано в публичной инфраструктуре

### README с badges

`README.md` полностью переписан по стандартам GitHub open-source проектов:

- Badges line вверху (License, Stage, Platform, Docker, PRs Welcome).
- Двуязычность (RU/EN) в каждой секции.
- ASCII-диаграмма архитектуры.
- Таблица стека с версиями и ролями.
- Таблица документации со всеми ссылками.
- Quick Start — реально работающий, шаг за шагом.
- Ссылки на CODE_OF_CONDUCT.md и CONTRIBUTING.md.

### CODE_OF_CONDUCT.md

Добавлен стандартный Contributor Covenant v2.1 (двуязычный, RU + EN).
Контактный email для репортов: `a.e.borovskoy@gmail.com`.

### GitHub Actions (CI/CD)

| Workflow | Файл | Назначение |
|---|---|---|
| Security Check | `.github/workflows/secrets-check.yml` | Проверка секретов при push/PR на `main` |
| Validate Compose | `.github/workflows/validate-compose.yml` | Валидация Docker Compose при push/PR |

Оба workflow запускаются автоматически при push в `main` и при открытии pull request.

### Issue Templates

| Шаблон | Файл | Назначение |
|---|---|---|
| Bug report | `.github/ISSUE_TEMPLATE/bug_report.md` | Двуязычный баг-репорт с полями окружения и checklist |
| Feature request | `.github/ISSUE_TEMPLATE/feature_request.md` | Запрос новой функциональности |
| Config | `.github/ISSUE_TEMPLATE/config.yml` | Конфигурация шаблонов |

PR template: `.github/pull_request_template.md`.
Владельцы кода: `.github/CODEOWNERS`.

---

## 10. Чеклист перед первым публичным релизом

Выполнить перед тегом `v0.1.0` и публикацией репозитория:

### Безопасность

- [ ] Запустить `./scripts/security/check_no_secrets.sh` — вывод чистый.
- [ ] Проверить `find . -name '.env' -o -name '*.key' -o -name '*.pem' -o -name '*.p12'` — ничего реального.
- [ ] Убедиться, что `config/.env` в `.gitignore` и не стейджится.
- [ ] Убедиться, что `external_docs/` в `.gitignore`.
- [ ] Убедиться, что нет реальных IP, доменов, серийных номеров в коде и документации.
- [ ] Убедиться, что нет реальных токенов и паролей в коде и документации.

### Документация

- [ ] `README.md` — badges рабочие, ссылки не битые.
- [ ] `CODE_OF_CONDUCT.md` — создан и добавлен в репозиторий.
- [ ] `CONTRIBUTING.md` — актуален.
- [ ] `SECURITY.md` — актуален.
- [ ] `CHANGELOG.md` — содержит запись `[0.1.0]`.
- [ ] `LICENSE` — присутствует (MIT).
- [ ] `AGENTS.md` — присутствует (для Codex/агентов).

### Код и конфигурация

- [ ] `config/.env.example` — содержит только placeholder-значения, нет реальных секретов.
- [ ] `docker compose -f docker/compose/docker-compose.stage1.yml config` — синтаксис валиден.
- [ ] `shellcheck scripts/**/*.sh` — нет критических ошибок.

### GitHub Infrastructure

- [ ] Issue templates настроены (`.github/ISSUE_TEMPLATE/`).
- [ ] PR template настроен (`.github/pull_request_template.md`).
- [ ] CI workflows активны (`.github/workflows/`).
- [ ] CODEOWNERS настроен.
- [ ] GitHub labels созданы (см. раздел 7).
- [ ] GitHub Discussions или Issues включены для сообщества.
- [ ] Description и Topics репозитория заполнены на GitHub.

### Необязательно, но желательно для первого релиза

- [ ] Скриншот или GIF quick start flow.
- [ ] Метки `good-first-issue` на 2-3 первых задачах.
- [ ] Первый release tag `v0.1.0` на GitHub с release notes из CHANGELOG.
