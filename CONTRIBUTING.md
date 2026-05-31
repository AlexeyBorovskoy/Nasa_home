# Участие в проекте / Contributing

## Русская версия

Вклад приветствуется, но проект связан с домашней инфраструктурой и персональными данными, поэтому изменения должны быть маленькими, проверяемыми и безопасными.

### Правила

1. Не коммитить секреты.
2. Не добавлять персональные данные в примеры, тесты, логи и документацию.
3. Предпочитать маленькие pull request.
4. Добавлять документацию к каждому операционному скрипту.
5. Сохранять Stage 1 безопасным: по умолчанию не открывать сервисы в публичный интернет.
6. Не добавлять локальную LLM на Jetson Nano в Stage 1.
7. Для рискованных изменений описывать rollback.

### Хорошие первые задачи

- Улучшить hardware audit script.
- Добавить заметки для Raspberry Pi 4/5.
- Добавить скриншоты безопасной тестовой установки.
- Добавить инструкцию по Xiaomi/HyperOS background sync.
- Добавить CI-проверку Docker Compose и shell-скриптов.
- Синхронизировать устаревшие архитектурные документы с текущим деревом.

## English Version

Contributions are welcome, but this project is related to home infrastructure and personal data, so changes should be small, reviewable, and safe.

### Rules

1. Do not commit secrets.
2. Do not include personal data in examples, tests, logs, or documentation.
3. Prefer small pull requests.
4. Add documentation for every operational script.
5. Keep Stage 1 safe: no public port exposure by default.
6. Do not add local LLM inference on Jetson Nano in Stage 1.
7. For risky changes, document rollback.

### Good First Issues

- Improve the hardware audit script.
- Add Raspberry Pi 4/5 notes.
- Add screenshots from a safe test installation.
- Add a Xiaomi/HyperOS background sync guide.
- Add CI validation for Docker Compose and shell scripts.
- Synchronize outdated architecture documents with the current tree.
