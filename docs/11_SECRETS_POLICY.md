# 11. Политика секретов / Secrets Policy

## 1. Запрещено коммитить / Never commit

```text
.env
.env.local
*.key
*.pem
*.p12
*.pfx
secrets/
DB dumps / дампы БД
API tokens / токены
SSH private keys / приватные SSH-ключи
config/secrets.json
```

## 2. Разрешено коммитить / Safe to commit

```text
.env.example
*.example.yaml
documentation without real keys / документацию без реальных ключей
scripts without secrets / скрипты без секретов
```

## 3. Права на локальные файлы / Local file permissions

```bash
chmod 600 .env
chmod 700 secrets
chmod 600 config/secrets.json
```

## 4. Проверка перед push / Pre-push check

```bash
./scripts/security/check_no_secrets.sh

# Or manual grep / Или вручную:
grep -RInE "(api[_-]?key|secret|token|password|BEGIN .*PRIVATE KEY|Bearer )" . \
  --exclude-dir=.git \
  --exclude='*.md' \
  --exclude='.env.example'
```

🇷🇺 Для публичного проекта рекомендуется подключить GitHub secret scanning и pre-commit hooks.
🇬🇧 For a public project, enable GitHub secret scanning and pre-commit hooks.

## 5. Актуальные секреты / Current secrets location

🇷🇺 Все операционные секреты — в `config/secrets.json` (gitignored). Никогда не коммитить этот файл.
🇬🇧 All operational secrets are in `config/secrets.json` (gitignored). Never commit this file.
