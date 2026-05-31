# 11. Политика секретов

## 1. Запрещено коммитить

```text
.env
.env.local
*.key
*.pem
*.p12
*.pfx
secrets/
DB dumps
API tokens
SSH private keys
```

## 2. Разрешено коммитить

```text
.env.example
*.example.yaml
документацию без реальных ключей
скрипты без секретов
```

## 3. Права на локальные файлы

```bash
chmod 600 .env
chmod 700 secrets
```

## 4. Проверка перед push

```bash
grep -RInE "(api[_-]?key|secret|token|password|BEGIN .*PRIVATE KEY|Bearer )" . \
  --exclude-dir=.git \
  --exclude='*.md' \
  --exclude='.env.example'
```

Для публичного проекта желательно подключить GitHub secret scanning и pre-commit hooks.
