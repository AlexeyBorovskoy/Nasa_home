# NVMe USB Box — Исследование для Jetson NAS / Research for Jetson NAS

> 🇷🇺 Дата: 2026-06-27 | Контекст: замена DEXP бокса (RTL9210B-CG) на надёжное решение. Магазин: DNS (dns-shop.ru).
> 🇬🇧 Date: 2026-06-27 | Context: replacing the DEXP enclosure (RTL9210B-CG) with a reliable alternative. Store: DNS (dns-shop.ru).

---

## Контекст задачи

- **Jetson Nano**: USB 3.0 hub (5 Gbps практический потолок скорости)
- **Режим**: 24/7 NAS, умеренная нагрузка (фото/видео бэкап)
- **Проблема текущего чипа**: RTL9210B-CG падает в bad state при USB reset → требует физического отключения питания
- **Требования**: надёжный чип с хорошей поддержкой Linux, алюминий для пассивного охлаждения

---

## Чипы: какие безопасны, какие нет

| Чип | Вердикт | Причина |
|---|---|---|
| **ASMedia ASM2362** | ✅ НАДЁЖНЫЙ | Хорошая Linux поддержка, стабильный; греется, но не крашится |
| **JMicron JMS583** | ✅ НАДЁЖНЫЙ | Холоднее ASM2362, стабильный, рекомендован сообществом для 24/7 |
| **ASMedia ASM2364** | ✅ OK | USB 3.2 Gen 2x2 (20Gbps), избыточно для Jetson, но надёжен |
| **Realtek RTL9210** | ❌ ИЗБЕГАТЬ | Тот же семейство что RTL9210B-CG — та же болезнь |
| **Realtek RTL9210B-CG** | ❌ ИЗБЕГАТЬ | Наш текущий кошмар: входит в bad state, не сбрасывается через software |

---

## Модели в DNS

### 1. UGREEN CM767 — **РЕКОМЕНДУЮ** ⭐
- **Цена**: ~1750–2050 ₽
- **Чип**: ASM2362 (подтверждено: UGREEN использует ASM2362 в этом классе)
- **Интерфейс**: USB 3.2 Gen 2 (10 Gbps), Type-C
- **Поддержка**: NVMe M-Key, 2230/2242/2260/2280
- **Корпус**: алюминий, пассивное охлаждение
- **Linux**: UGREEN + ASM2362 = стабильно (подтверждено на OpenWrt/Raspberry Pi)
- **Минус**: только NVMe (не поддерживает SATA M.2)
- [dns-shop.ru/product/f5eb8d381e81763c](https://www.dns-shop.ru/product/f5eb8d381e81763c/m2-vnesnij-boks-ugreen-cm767/)

### 2. UGREEN CM400 — альтернатива (dual NVMe+SATA)
- **Цена**: ~2500–3300 ₽
- **Чип**: ASM2362 / вероятно ASM2364
- **Интерфейс**: USB 3.2 Gen 2 (10 Gbps)
- **Поддержка**: NVMe + SATA (двойной протокол) → можно использовать текущий SATA диск
- **Плюс**: заменяет и SATA бокс и даёт NVMe
- [dns-shop.ru/product/61e026731443ed20](https://www.dns-shop.ru/product/61e026731443ed20/m2-vnesnij-boks-ugreen-cm400/)

### 3. ARDOR GAMING WARD — бюджетный вариант (⚠️ риск)
- **Цена**: ~2199 ₽
- **Чип**: неизвестен (не раскрывается производителем)
- **Интерфейс**: USB 3.2 Gen 1 (5 Gbps) — для Jetson достаточно
- **Корпус**: алюминий, противоударный
- **Риск**: неизвестный чип = неизвестная надёжность
- [dns-shop.ru/product/31612c9b29700f94](https://www.dns-shop.ru/product/31612c9b29700f94/m2-vnesnij-boks-ardor-gaming-ward/)

### ❌ ARDOR GAMING M2 Arctic Red — НЕ БРАТЬ
- Чип: **RTL9210** (подтверждено из технических источников)
- Несмотря на 862 отзыва и рейтинг 4.74 — тот же класс проблем что RTL9210B-CG
- Есть отзыв "чуть не потерял данные" (irecommend.ru)

### ❌ UGREEN CM559 — РИСКОВАННЫЙ
- Существуют версии с JMS583 (хорошо) и с RTL9210B (плохо)
- Нет гарантии что попадёт нужная ревизия при заказе
- Отсутствует в DNS → не рассматривается

---

## Итоговая рекомендация

| Вариант | Цена | Чип | Для Jetson | Вердикт |
|---|---|---|---|---|
| **UGREEN CM767** | ~1800₽ | ASM2362 | ✅ | ⭐ Лучший выбор |
| **UGREEN CM400** | ~2800₽ | ASM2362 | ✅ | Если нужен и SATA |
| ARDOR GAMING WARD | ~2200₽ | неизвестен | ✅ | Риск |
| ARDOR GAMING Arctic Red | ~? | RTL9210 | ❌ | Не брать |

**Вывод**: UGREEN CM767 за ~1800₽ — самый дешёвый надёжный вариант в DNS с известным
чипом (ASM2362), алюминиевым корпусом и хорошей поддержкой Linux.

---

## Важно: нужен ли новый NVMe диск?

Текущий диск в DEXP боксе — **M.2 SATA**. CM767 поддерживает только NVMe.
Варианты:
- **Купить CM767 + новый NVMe SSD** — полный апгрейд
- **Купить CM400** — поддерживает и SATA (можно переткнуть текущий диск) и NVMe

---

## Онлайн-магазины с доставкой сегодня в СПб

> Исследование 2026-06-27. Магазины с возможностью получить товар сегодня.

### Вариант A: 3delectronics.ru — JMS583 бокс, **990 ₽** ⭐ ДЕШЕВЛЕ ВСЕГО
- **Чип**: JMS583 (надёжный, холодный)
- **Цена**: 990 ₽
- **Корпус**: алюминий, NVMe, 2230/42/60/80
- **USB**: 3.1 Gen2 10Gbps, два кабеля (Type-A + Type-C)
- **Доставка**: до 5 дней курьером. Есть офис в СПб: **8 (812) 317-67-72** — уточнить самовывоз сегодня
- **Ссылка**: [3delectronics.ru/box-nvme-m2-black-v2-1.html](https://3delectronics.ru/box-nvme-m2-black-v2-1.html)
- **Вердикт**: если дадут самовывоз сегодня — это наилучший выбор

### Вариант B: DNS самовывоз — UGREEN CM767, **~1800 ₽**
- **Чип**: ASM2362 (надёжный)
- **Цена**: ~1750–2050 ₽
- **Самовывоз**: сегодня из любого DNS в СПб (много точек)
- **Ссылка**: [dns-shop.ru CM767](https://www.dns-shop.ru/product/f5eb8d381e81763c/m2-vnesnij-boks-ugreen-cm767/)
- **Вердикт**: самый доступный гарантированный вариант с надёжным чипом

### Вариант C: Ozon Express — JMS583 боксы, **цена неизвестна (редиректы)**
- На Ozon есть боксы с JMS583 (артикул 1194565135)
- Ozon Express в СПб — доставка в тот же день
- **Действие**: зайти на ozon.ru → фильтр "доставка сегодня" → поиск "NVMe бокс JMS583"
- Ориентир цены: аналогичные товары ~900–1500 ₽

### Вариант D: Citilink самовывоз — AgeStar 31UBNV1C, **~1900–2700 ₽**
- **Чип**: неизвестен (⚠️ может быть RTL9210 — риск!)
- **Самовывоз**: сегодня из магазинов Citilink в СПб
- **Вердикт**: дороже DNS + чип под вопросом → не рекомендуется

### ❌ Orient UHD-524 (Nix.ru, Ozon) — НЕ БОКС
- Это **открытый адаптер без корпуса** (PCB без алюминиевого кейса)
- Не подходит для постоянного NAS-использования

---

## Алгоритм действий для покупки СЕГОДНЯ

```
1. Позвонить в 3delectronics.ru: 8 (812) 317-67-72
   → Спросить: есть ли самовывоз бокса JMS583 (NVMe M.2) сегодня?
   → Если ДА: взять за 990 ₽ ✅

2. Если нет самовывоза в 3d:
   → Проверить Ozon Express (ozon.ru): фильтр "доставка сегодня" СПб
     + поиск "NVMe бокс JMS583" или "NVMe корпус M.2 алюминий"
   → Если есть: заказать (~900-1500 ₽)

3. Если Ozon тоже мимо:
   → Идти в ближайший DNS и брать UGREEN CM767 (~1800 ₽)
   → 100% гарантия надёжного чипа ASM2362, сегодня же
```

---

## Источники

- [iXBT: Обзор CM238 (ASM2362)](https://www.ixbt.com/live/data/obzor-vneshnego-boksa-ugreen-enclosure-c-podderzhkoy-m2-nakopiteley-protokola-nvme.html)
- [iXBT: Обзор CM559](https://www.ixbt.com/live/data/obzor-ssd-karmana-ugreen-cm559-c-podderzhkoy-m2-nakopiteley-protokolov-nvme-i-sata.html)
- [iXBT: 10 боксов NVMe протестировано](https://www.ixbt.com/live/topcompile/vybiraem-universalnyy-vneshniy-boks-dlya-m2-nvme-ssd-so-skorostnoy-peredachi-ot-10-gbit-s-10-variantov-protestirovannyh-lichno.html)
- [iXBT: ASM2362 vs JMS583](https://www.ixbt.com/data/usb-pcie-boxes-asmedia-jmicron-review.html)
- [AnandTech: Stable NVMe USB (community)](https://forums.anandtech.com/threads/stable-nvme-usb-adapter.2572973/)
- [OpenWrt: UGREEN + ASM2362 на Linux](https://forum.openwrt.org/t/ugreeen-174c-2362-asm2362-rpi4-help/99403)
- [DNS: UGREEN CM767](https://www.dns-shop.ru/product/f5eb8d381e81763c/m2-vnesnij-boks-ugreen-cm767/)
- [DNS: UGREEN CM400](https://www.dns-shop.ru/product/61e026731443ed20/m2-vnesnij-boks-ugreen-cm400/)
