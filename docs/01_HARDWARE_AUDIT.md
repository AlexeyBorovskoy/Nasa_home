# 01. Аппаратный аудит

## 1. Цель

До развёртывания сервисов необходимо зафиксировать фактическое состояние Jetson Nano, HDD, сети и ОС.

## 2. Исходное оборудование

| Компонент | Предварительно определено |
|---|---|
| SBC | NVIDIA Jetson Nano Developer Kit |
| Роутер | TP-Link EC220-G5 |
| HDD | USB HDD, питание предусмотрено отдельно |
| Системный носитель | microSD 64 GB |
| Сеть | Ethernet для Jetson |

## 3. Команды аудита

```bash
uname -a
cat /etc/os-release
free -h
df -h
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL,SERIAL
lsusb
ip a
ip route
sudo dmesg | grep -i -E "usb|sd|error|reset|fail|i/o" | tail -n 200
```

## 4. Проверка Jetson

```bash
sudo nvpmodel -q || true
sudo tegrastats --interval 1000 || true
```

Если `tegrastats` отсутствует, установить или зафиксировать как отсутствие инструмента.

## 5. Проверка HDD

```bash
sudo apt update
sudo apt install -y smartmontools
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL,SERIAL
sudo smartctl -a /dev/sda || sudo smartctl -a -d sat /dev/sda || true
```

## 6. Критерии допуска к следующему этапу

| Критерий | Норма |
|---|---|
| HDD виден в `lsblk` | Да |
| В `dmesg` нет повторяющихся USB reset/I/O error | Да |
| RAM свободна после старта | Не менее 1 GB желательно |
| Температура Jetson без нагрузки | Стабильная, без throttling |
| Jetson доступен по SSH | Да |
| IP закреплён на роутере | Да |

## 7. Результат

Результаты аудита сохраняются в:

```text
runtime/audit/HARDWARE_AUDIT_REPORT.md
```

Этот каталог не коммитится в публичный репозиторий, если содержит серийные номера или внутренние IP.
