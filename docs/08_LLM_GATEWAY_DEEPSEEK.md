# 08. LLM Gateway / DeepSeek

## 1. Назначение / Purpose

🇷🇺 LLM Gateway — отдельный сервис, который изолирует домашнее облако от прямой интеграции с DeepSeek API.
🇬🇧 LLM Gateway is a dedicated service that isolates the home cloud from direct DeepSeek API integration.

## 2. Почему шлюз обязателен / Why the gateway is mandatory

🇷🇺 Без шлюза каждый сервис начнёт самостоятельно обращаться к LLM, что создаёт риски:
🇬🇧 Without the gateway each service would call the LLM independently, creating risks:

- 🇷🇺 утечка персональных данных / 🇬🇧 personal data leak
- 🇷🇺 отсутствие лимитов расходов / 🇬🇧 no spending limits
- 🇷🇺 неуправляемые промты / 🇬🇧 uncontrolled prompts
- 🇷🇺 сложность смены провайдера / 🇬🇧 hard to switch providers
- 🇷🇺 невозможность аудита / 🇬🇧 no audit trail

## 3. Провайдер / Provider

🇷🇺 DeepSeek API поддерживает формат, совместимый с OpenAI/Anthropic API. Это позволяет использовать OpenAI-compatible SDK и в будущем заменить провайдера без полной переработки логики.
🇬🇧 DeepSeek API uses an OpenAI/Anthropic-compatible format. This allows using OpenAI-compatible SDKs and swapping providers in the future without a full rewrite.

## 4. Модели / Models

🇷🇺 Текущая конфигурация / 🇬🇧 Current configuration:

```env
LLM_PROVIDER=deepseek
DEEPSEEK_BASE_URL=https://api.deepseek.com
DEEPSEEK_MODEL=deepseek-chat
DEEPSEEK_REASONER_MODEL=deepseek-reasoner
```

🇷🇺 `deepseek-chat` / `deepseek-reasoner` — рабочие имена DeepSeek API (подтверждено живым вызовом 2026-05-31). Имена `deepseek-v4-flash` / `deepseek-v4-pro` зарезервированы на будущее и сейчас API не принимаются.
🇬🇧 `deepseek-chat` / `deepseek-reasoner` are the live DeepSeek API names (confirmed by live call 2026-05-31). Names `deepseek-v4-flash` / `deepseek-v4-pro` are reserved for the future and are not accepted by the API now.

## 5. Разрешённые сценарии Stage 1 / Allowed Stage 1 scenarios

| Сценарий / Scenario | Разрешено / Allowed |
|---|---:|
| Анализ обезличенных логов / Analyze anonymized logs | Да / Yes |
| Объяснение ошибок Docker / Explain Docker errors | Да / Yes |
| Формирование runbook / Generate runbook | Да / Yes |
| Помощь с командами диагностики / Help with diagnostic commands | Да / Yes |
| Работа с проектной документацией / Project documentation | Да / Yes |
| Анализ личных фото/видео / Analyze personal photos/videos | Нет / No |
| Анализ контактов и календаря / Analyze contacts & calendar | Нет / No |
| Анализ личных документов / Analyze personal documents | Нет / No |
| Передача backup-архивов / Send backup archives | Нет / No |

## 6. API шлюза / Gateway API

```http
GET /health
POST /v1/chat
POST /v1/diagnostics/explain
POST /v1/runbook/generate
```

🇷🇺 Пример запроса / 🇬🇧 Example request:

```json
{
  "task": "explain_docker_error",
  "context": "service immich-server restarted 3 times, no personal data",
  "mode": "safe"
}
```

## 7. Privacy-фильтр / Privacy filter

🇷🇺 Перед отправкой в DeepSeek сервис должен удалять:
🇬🇧 Before sending to DeepSeek the service must strip:

- e-mail
- 🇷🇺 телефоны / 🇬🇧 phone numbers
- 🇷🇺 токены / 🇬🇧 tokens
- 🇷🇺 ключи / 🇬🇧 keys
- 🇷🇺 пароли / 🇬🇧 passwords
- 🇷🇺 точные адреса / 🇬🇧 exact addresses
- 🇷🇺 персональные имена / 🇬🇧 personal names
- 🇷🇺 пути, раскрывающие личные данные / 🇬🇧 paths revealing personal data

## 8. Логирование / Logging

🇷🇺 По умолчанию / 🇬🇧 By default:

```env
LLM_LOG_PROMPTS=false
LLM_LOG_RESPONSES=false
LLM_REDACT_PERSONAL_DATA=true
```

🇷🇺 Логировать можно только метаданные:
🇬🇧 Only metadata may be logged:

- 🇷🇺 время запроса / 🇬🇧 request timestamp
- 🇷🇺 тип задачи / 🇬🇧 task type
- 🇷🇺 модель / 🇬🇧 model
- 🇷🇺 оценка токенов / 🇬🇧 token estimate
- 🇷🇺 статус ответа / 🇬🇧 response status
- 🇷🇺 ошибка при наличии / 🇬🇧 error if any
