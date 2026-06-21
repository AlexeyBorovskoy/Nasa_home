# ADR-0004: Tailscale для внешнего доступа (Stage 2)

## Статус

**Заменено** ADR-0005 (2026-06-21). Tailscale не реализован — выбран VPS + autossh reverse SSH tunnel.
Причина: данные Tailscale проходят через DERP-серверы третьей стороны; VPS уже есть в проекте.
См. [ADR-0005-vps-autossh-reverse-tunnel.md](ADR-0005-vps-autossh-reverse-tunnel.md).

## Контекст

После провала двух VPN-попыток (ADR-0003) нужно решение для внешнего доступа из мобильной сети.

Требования: CGNAT-proof, не трогает Amnezia, простая установка, бесплатно до 100 устройств.

## Рассмотренные варианты

| Вариант | CGNAT | Независим от Amnezia | Сложность |
|---------|-------|---------------------|-----------|
| wg-nasa | ✗ | да | высокая |
| Amnezia Desktop App | частично | нет | средняя |
| ngrok/cloudflared | ✓ | да | низкая, НО данные через третью сторону |
| **Tailscale** | ✓ DERP-relay | да | очень низкая |
| ZeroTier | ✓ | да | низкая |

## Решение

**Tailscale** — userspace WireGuard с DERP-relay для обхода CGNAT.

- Устанавливается как userspace-демон, не конфликтует с Amnezia.
- Jetson получает IP из диапазона `100.x.x.x`.
- Android-телефон подключается через Tailscale App.
- Трафик зашифрован (WireGuard), при CGNAT идёт через DERP-серверы Tailscale.

## Реализация

Подробный план: `docs/plans/TAILSCALE_ACCESS_PLAN.md`.

```bash
# На Jetson
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
tailscale ip -4   # → 100.x.x.x
```

После настройки добавить Tailscale IP в `NEXTCLOUD_TRUSTED_DOMAINS`.

## Последствия

- Бесплатно до 100 устройств; требует аккаунт Tailscale.
- При недоступности серверов Tailscale — LAN продолжает работать.
- Не требует изменений в роутере или Amnezia.