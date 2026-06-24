# GitHub Traffic Metrics — NASA Home Cloud

Ежедневный мониторинг посещаемости и вовлечённости репозитория.
Данные берём через `gh api` (14-дневное окно GitHub).

**Команды для обновления:**
```bash
gh api repos/AlexeyBorovskoy/Nasa_home/traffic/views --jq '{views: .count, uniques: .uniques}'
gh api repos/AlexeyBorovskoy/Nasa_home/traffic/clones --jq '{clones: .count, uniques: .uniques}'
gh api repos/AlexeyBorovskoy/Nasa_home/traffic/popular/referrers
gh api repos/AlexeyBorovskoy/Nasa_home --jq '{stars: .stargazers_count, forks: .forks_count, watchers: .watchers_count}'
```

---

## Дневной лог / Daily log

| Дата | Views (14d) | Uniq visitors | Clones (14d) | Uniq cloners | Stars | Forks | Топ источник | Примечание |
|---|---|---|---|---|---|---|---|---|
| 2026-06-24 | 0 | 0 | 371 | 149 | 0 | 0 | — | Репо публично с 21.06; клоны вероятно боты/scrapers |

---

## Анализ / Analysis

### 2026-06-24 — Стартовая точка

**Состояние:** репозиторий публичен с 2026-06-21 (3 дня).

**Что видим:**
- 371 клон / 149 уникальных клонеров за 14 дней — значительное число для 3-дневного проекта
- 0 просмотров страницы — расхождение с клонами указывает на автоматические клоны (GitHub indexers, боты, зеркала)
- 0 звёзд, 0 форков — органическое открытие ещё не началось
- Нет входящих реферреров — проект не был нигде опубликован / упомянут

**Вывод:** базовая линия установлена. Реальный органический трафик начнётся после публикации на Habr / Reddit / GitHub Trending.

**Что влияет на рост:**
- Публикация Habr-статьи (черновик: `docs/articles/habr_draft.md`)
- Упоминание в r/selfhosted, r/homelab, r/degoogle
- HTTPS на VPS (доверие к проекту)
- Добавление "Use this template" кнопки
- Скриншоты реального UI в README

---

## Целевые метрики / Target metrics (90 дней)

| Метрика | Цель | Статус |
|---|---|---|
| GitHub Stars | 50 | 0 / 50 |
| Уникальные клонеры | 500 | 149 / 500 |
| Уникальные посетители/нед | 100 | 0 / 100 |
| Habr публикация | 1 | 0 / 1 |
| Reddit posts | 2 | 0 / 2 |
| Issues от внешних users | 3 | 0 / 3 |
| Forks | 5 | 0 / 5 |
