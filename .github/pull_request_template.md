<!--
RU: Перед отправкой PR убедись, что нет реальных .env, ключей, паролей, токенов и персональных данных.
EN: Before submitting, make sure there are no real .env files, keys, passwords, tokens, or personal data.
-->

## Описание изменений / Description of Changes

<!--
RU: Что именно изменено и зачем?
EN: What exactly was changed and why?
-->

## Тип изменения / Type of Change

- [ ] `bugfix` — исправление бага / bug fix
- [ ] `feature` — новая возможность / new feature
- [ ] `docs` — документация / documentation
- [ ] `chore` — рефакторинг, зависимости, инфраструктура / refactoring, dependencies, infrastructure

## Stage проекта / Project Stage

- [ ] Stage 0 — подготовка microSD / microSD prep
- [ ] Stage 1A — hardware audit, storage, Samba/SFTP
- [ ] Stage 1B — Nextcloud
- [ ] Stage 1C — Immich
- [ ] Stage 1D — LLM Gateway (DeepSeek)
- [ ] Stage 1E — Backup/Restore
- [ ] Stage 2 — Android client
- [ ] Stage 3 — analytics / RAG
- [ ] Инфраструктура репозитория / Repository infrastructure

## Тестирование / Testing

<!--
RU: Что ты проверил? На каком оборудовании? Укажи конкретные команды и их вывод (без секретов).
EN: What did you test? On what hardware? List specific commands and their output (no secrets).
-->

- [ ] RU: Проверено локально / EN: Tested locally
- [ ] RU: Docker Compose `config` прошёл без ошибок / EN: Docker Compose `config` passed without errors
- [ ] RU: Shell-скрипты прошли проверку синтаксиса / EN: Shell scripts passed syntax check

## Чеклист / Checklist

- [ ] RU: В PR нет реальных `.env`, API-ключей, паролей, приватных ключей, SSH-ключей и персональных данных.
      EN: This PR contains no real `.env`, API keys, passwords, private keys, SSH keys, or personal data.
- [ ] RU: Я запустил `./scripts/security/check_no_secrets.sh` — вывод чистый.
      EN: I ran `./scripts/security/check_no_secrets.sh` — output is clean.
- [ ] RU: Документация обновлена (если изменения затрагивают поведение или конфигурацию).
      EN: Documentation is updated (if the change affects behavior or configuration).
- [ ] RU: Для рискованных изменений описан rollback.
      EN: For risky changes, a rollback procedure is documented.
- [ ] RU: Изменения совместимы с ограничениями Jetson Nano (RAM, CPU, ARM64).
      EN: Changes are compatible with Jetson Nano constraints (RAM, CPU, ARM64).
