# 01A. Jetson SD Bootstrap

## 1. Цель

Подготовить Jetson Nano к первому запуску, если готовой загрузочной microSD
карты ещё нет, а USB HDD пока недоступен.

Этот шаг предшествует `docs/01_HARDWARE_AUDIT.md`: сначала нужно получить
загружаемый Jetson, настроить первый вход и сеть, и только потом выполнять
полный аппаратный аудит.

## 2. Что меняется

На ноутбуке:

- выбирается официальный образ Jetson Nano Developer Kit SD Card Image;
- скачивается архив образа;
- проверяется наличие microSD-карты и кардридера;
- подготавливается безопасный порядок записи образа.

На Jetson:

- вставляется подготовленная microSD;
- выполняется первый boot;
- настраивается пользователь, пароль, hostname и сеть;
- проверяется доступ по SSH.

HDD на этом шаге не нужен и не подключается.

## 3. Почему меняется

Проект нельзя начинать с Docker, Nextcloud или storage-аудита, пока Jetson не
имеет рабочей ОС. Для Jetson Nano Developer Kit базовый путь старта — записать
официальный SD Card Image на microSD и загрузиться с неё.

## 4. Какие файлы затрагиваются

В репозитории меняется только документация:

- `docs/01A_JETSON_SD_BOOTSTRAP.md`

Runtime-артефакты не коммитятся:

- скачанный `.zip` образ;
- распакованный `.img`;
- логи первого запуска;
- серийные номера;
- локальные IP.

Рекомендуемое локальное место для образов:

```text
/home/alexey/downloads/jetson/
```

или любой внешний каталог вне Git-репозитория.

## 5. Исходные вводные

| Пункт | Текущее состояние |
|---|---|
| Готовая стартовая microSD | нет |
| HDD | пока недоступен |
| Цель первого этапа | загрузить Jetson и получить SSH |
| Основной источник образа | официальная страница NVIDIA Jetson Nano Developer Kit |
| Метод записи | balenaEtcher или Linux CLI после ручного выбора устройства |

## 6. Что нужно физически

Минимум:

- Jetson Nano Developer Kit;
- microSD 64 GB или больше, UHS-I, желательно High Endurance;
- кардридер microSD для ноутбука;
- стабильное питание Jetson;
- Ethernet-кабель;
- доступ к роутеру для DHCP/static lease;
- ноутбук с интернетом.

Для headless setup:

- micro-USB кабель data-capable, не только зарядный;
- питание Jetson через DC barrel jack, если micro-USB занят под serial/device mode.

Для setup через монитор:

- HDMI или DisplayPort монитор;
- USB-клавиатура;
- USB-мышь.

## 7. Официальные источники

Использовать только официальные NVIDIA-страницы:

- Jetson Nano Developer Kit Getting Started:
  `https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit`
- JetPack 4.x installation documentation:
  `https://docs.nvidia.com/jetson/jetpack/4.6/install-jetpack/index.html`

Важное уточнение: Jetson Nano относится к JetPack 4.x / L4T r32-линейке.
Нельзя брать образ для Jetson Orin Nano или других Jetson-плат без явного
подтверждения модели.

## 7.1. Локальные материалы в проекте

В проект перенесён локальный каталог внешних материалов:

```text
/home/alexey/work/NASA/external_docs/jatson
```

Он не коммитится в GitHub, потому что содержит большие сторонние бинарные
файлы. Состав, размеры и checksums зафиксированы в:

```text
docs/references/JETSON_LOCAL_ASSETS.md
```

Для текущего Stage 0 уже есть локальный SD-образ:

```text
external_docs/jatson/jetson-nano-jp461-sd-card-image.zip
```

и локальный Etcher:

```text
external_docs/jatson/balenaEtcher-linux-x64-2.1.6.zip
```

Если checksum совпадает с manifest, повторно скачивать образ не нужно.

## 8. Команды инвентаризации на ноутбуке

До скачивания образа:

```bash
mkdir -p /home/alexey/downloads/jetson
df -h /home/alexey/downloads/jetson
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL,SERIAL
```

После вставки microSD:

```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL,SERIAL
dmesg | tail -n 50
```

Нужно вручную определить устройство microSD, например `/dev/sdX` или
`/dev/mmcblkX`. Нельзя угадывать имя устройства.

## 9. Скачивание образа

Безопасный порядок:

1. Открыть официальный NVIDIA Getting Started для Jetson Nano Developer Kit.
2. Скачать `Jetson Nano Developer Kit SD Card Image`.
3. Сохранить архив вне репозитория.
4. Зафиксировать имя файла, размер и checksum, если NVIDIA публикует checksum.

Для текущего проекта этот шаг уже частично выполнен: локальный архив находится
в `external_docs/jatson/`. Перед записью карты нужно только повторно проверить
checksum по `docs/references/JETSON_LOCAL_ASSETS.md`.

Пример проверки локального файла:

```bash
cd /home/alexey/downloads/jetson
ls -lh
sha256sum *.zip
```

Checksum нужно сравнить с официальным значением, если оно доступно на странице
загрузки или в NVIDIA Download Center.

## 10. Запись microSD

Рекомендуемый безопасный способ — balenaEtcher:

1. Select image: официальный `.zip` образ Jetson Nano.
2. Select target: только microSD.
3. Flash.
4. Дождаться validation.
5. Извлечь карту штатно.

CLI-способ допустим только после ручного подтверждения устройства:

```bash
# Пример. НЕ запускать без проверки /dev/sdX.
unzip -p jetson_nano_devkit_sd_card.zip | sudo dd of=/dev/sdX bs=1M status=progress conv=fsync
sudo eject /dev/sdX
```

`/dev/sdX` в примере должен быть заменён на реальное устройство microSD.
Неверный выбор устройства уничтожит данные на другом диске.

## 11. Первый boot

1. Вставить microSD в слот Jetson Nano.
2. Подключить Ethernet.
3. Выбрать режим первого запуска:
   - монитор + клавиатура + мышь;
   - headless через micro-USB serial/device mode.
4. Подключить питание.
5. Пройти первичную настройку Ubuntu/L4T:
   - принять license;
   - создать пользователя;
   - задать пароль;
   - выбрать hostname;
   - настроить timezone.

Рекомендуемый hostname:

```text
nasa-jetson
```

## 12. Проверка первого запуска

На Jetson:

```bash
uname -a
cat /etc/os-release
df -h
free -h
ip a
```

Проверка Jetson-инструментов:

```bash
sudo nvpmodel -q || true
sudo tegrastats --interval 1000 || true
```

Проверка SSH:

```bash
sudo systemctl status ssh || true
hostname -I
```

С ноутбука:

```bash
ssh <user>@<jetson-lan-ip>
```

## 13. Критерии допуска к аппаратному аудиту

| Критерий | Норма |
|---|---|
| Jetson загружается с microSD | да |
| Первый пользователь создан | да |
| Ethernet получил LAN IP | да |
| SSH работает из LAN | да |
| `df -h` видит root filesystem на microSD | да |
| Нет циклических boot errors | да |
| HDD не требуется | да |

После этого можно выполнять:

```bash
./scripts/diagnostics/hardware_audit.sh
```

## 14. Rollback

Если Jetson не загружается:

1. Не форматировать HDD и не менять роутер/firewall.
2. Проверить, что образ соответствует именно Jetson Nano Developer Kit.
3. Перезаписать microSD через balenaEtcher с validation.
4. Проверить питание.
5. Проверить другой кардридер или другую microSD.
6. Повторить первый boot.

Если была выбрана не та SD-карта при записи CLI-способом, автоматического
rollback нет. Поэтому CLI-запись разрешена только после ручного подтверждения
устройства.
