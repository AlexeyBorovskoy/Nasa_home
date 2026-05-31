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
