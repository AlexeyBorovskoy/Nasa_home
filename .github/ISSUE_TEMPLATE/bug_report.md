---
name: Bug report / Баг-репорт
about: Сообщить о проблеме / Report a problem
title: "[BUG] "
labels: bug
assignees: AlexeyBorovskoy
---

<!--
RU: Перед заполнением убедись, что в отчёте нет реальных паролей, ключей, токенов и персональных данных.
EN: Before submitting, make sure this report contains no real passwords, keys, tokens, or personal data.
-->

## Описание / Description

<!--
RU: Кратко опиши, что пошло не так.
EN: Briefly describe what went wrong.
-->

## Шаги воспроизведения / Steps to Reproduce

<!--
RU: Перечисли конкретные шаги, которые воспроизводят проблему.
EN: List the exact steps to reproduce the issue.
-->

1.
2.
3.

## Ожидаемое поведение / Expected Behavior

<!--
RU: Что должно было произойти?
EN: What should have happened?
-->

## Реальное поведение / Actual Behavior

<!--
RU: Что происходит на самом деле?
EN: What actually happens?
-->

## Окружение / Environment

| Поле / Field | Значение / Value |
|---|---|
| Jetson Nano model | Developer Kit 4 GB / 2 GB / other |
| L4T version (`cat /etc/nv_tegra_release`) | |
| Docker version (`docker version`) | |
| Docker Compose version (`docker compose version`) | |
| Nextcloud version (if relevant) | |
| Immich version (if relevant) | |
| LLM Gateway version / commit | |
| OS / SD card | |
| Storage device (USB HDD model) | |

## Логи / Logs

<!--
RU: Вставь сюда вывод `docker logs <container>` или `./scripts/diagnostics/hardware_audit.sh`.
    Убедись, что в логах нет секретов, паролей, ключей и личных данных.
EN: Paste `docker logs <container>` or `./scripts/diagnostics/hardware_audit.sh` output here.
    Make sure logs contain no secrets, passwords, keys, or personal data.
-->

<details>
<summary>docker logs / hardware_audit output</summary>

```
(paste here / вставь сюда)
```

</details>

## Чеклист / Checklist

- [ ] RU: Я проверил, что в этом отчёте нет реальных паролей, ключей, API-токенов и персональных данных.
      EN: I confirmed this report contains no real passwords, keys, API tokens, or personal data.
- [ ] RU: Я запустил `./scripts/security/check_no_secrets.sh` перед отправкой.
      EN: I ran `./scripts/security/check_no_secrets.sh` before submitting.
- [ ] RU: Я проверил существующие issues — такого бага ещё не сообщали.
      EN: I checked existing issues and this bug has not been reported yet.
