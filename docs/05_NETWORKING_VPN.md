# 05. Сеть и VPN

## 1. LAN-схема

```text
Домашний роутер (модель уточняется на месте)
├── 192.168.0.1       роутер (gateway, пример)
├── 192.168.0.50      Jetson Nano, статический DHCP lease (назначается позже)
├── 192.168.0.x       телефоны
└── 192.168.0.x       ноутбуки
```

> Подсеть и IP выше — пример. Jetson ставится с нуля: сетевые настройки на свежем
> образе — по умолчанию (DHCP), статический lease назначается уже на этапе
> переноса в домашнюю LAN, а не задаётся заранее.

## 1.1. Stage 0 direct-link схема

> Источник истины по первому подключению — **официальная документация NVIDIA**
> (локально: `external_docs/jetson/get-started-jetson-nano-devkit.html` и
> `external_docs/jatson/NV_Jetson_Nano_Developer_Kit_User_Guide.pdf`). По ней
> первичная настройка свежего Jetson Nano в headless-режиме идёт через
> **serial console по Micro-USB** (`/dev/ttyACM0`, скорость `115200`,
> `sudo screen /dev/ttyACM0 115200`), где проходит штатный first-boot setup
> Ubuntu (oem-config). Только после этого Jetson доступен по сети.

Для аппаратного аудита и SSH после first-boot используется прямое подключение
Jetson к ноутбуку по Ethernet. Это основная схема Stage 0 (после serial-настройки),
а не fallback:

```text
Ноутбук
├── обычный интернет/LAN интерфейс
└── USB-Ethernet adapter, ens37, 192.168.1.2/24
        |
        └── Jetson Nano, временный IP в 192.168.1.0/24
```

Домашний роутер в Stage 0 не используется. Эта схема нужна для bootstrap, SSH и
диагностики. Она не предназначена для публикации Nextcloud, Immich, Samba или
LLM Gateway.

Команды обнаружения:

```bash
ip -br addr
lsusb
ip neigh show dev ens37
nmap -sn 192.168.1.0/24
ssh <user>@<jetson-direct-link-ip>
```

После завершения Stage 0 Jetson переносится в основную LAN-схему через роутер,
где ему назначается static DHCP lease, например `192.168.0.50`.

Конкретная модель домашнего роутера и его gateway уточняются на месте — Jetson
ставится с нуля, заранее заданной сетевой конфигурации в проекте нет. На Stage 0
роутер вообще не трогаем: не менять firewall, port forwarding, DHCP reservations
или Wi-Fi параметры. Эти настройки актуальны только на этапе переноса Jetson в
домашнюю LAN.

## 1.2. USB device-mode доступ с Windows-хоста (recovery/admin, проверено 2026-06-13)

Если Jetson подключён по micro-USB к **Windows-хосту** (не к Linux-VM), L4T
device mode поднимает одновременно **4 интерфейса**:

- RNDIS Ethernet (в `Get-NetAdapter` — отдельный `Ethernet N`);
- NCM Ethernet (второй `Ethernet M`);
- USB-serial (`COMx`, `VID_0955` NVIDIA) — консоль `ttyGS0`/`ttyACM0`;
- USB Mass Storage (`L4T-README`, диск с инструкцией NVIDIA).

На стороне Jetson все эти интерфейсы объединены в бридж `l4tbr0`
(`192.168.55.1/24`).

**IPv4 `192.168.55.1` обычно недоступен с Windows-хоста** — у Windows нет
маршрута на `192.168.55.0/24` (IPv4 на RNDIS-адаптере не настраивается
автоматически). Рабочий вариант — **IPv6 link-local**:

```powershell
Get-NetAdapter                                   # найти ifIndex RNDIS-адаптера
ping -6 fe80::1%<ifIndex>
Test-NetConnection -ComputerName "fe80::1%<ifIndex>" -Port 22
ssh admin@fe80::1%<ifIndex>
```

`<ifIndex>` меняется между подключениями USB — каждый раз смотреть в
`Get-NetAdapter`.

Настройка ключевого SSH-доступа (на Windows нет `ssh-copy-id`):

```powershell
Get-Content ~/.ssh/id_ed25519.pub | ssh admin@fe80::1%<ifIndex> `
  "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && echo DONE"
```

После этого `ssh admin@fe80::1%<ifIndex>` работает без пароля.

> На Jetson `sudo` для пользователя `admin` требует пароль (NOPASSWD не
> настроен) — для административных команд (`systemctl`, `nmcli`, правки в
> `/etc/`) пароль нужен отдельно от SSH-ключа.

Эта схема — **recovery/admin-доступ** на время, пока Jetson не в домашней LAN
или для диагностики. Основной канал для сервисов — `nasa-lan` (eth0, см.
§1).

## 2. Правило публикации сервисов

На первом этапе запрещено публиковать наружу:

- 22/SSH;
- 80/443 Nextcloud;
- 2283 Immich;
- 445 Samba;
- 8090 LLM Gateway.

Доступ извне только через VPN.

## 3. VPN-варианты

| Вариант | Назначение | Оценка |
|---|---|---|
| Tailscale | быстрый старт без белого IP | удобно |
| ZeroTier | mesh-сеть | удобно |
| WireGuard через VPS | контролируемая инженерная схема | предпочтительно для продакшн |
| AmneziaVPN | если уже используется | возможно |

## 3.1. Доступный VPS/VPN контур

В `/home/alexey/work/Amnezia` уже есть рабочий WireGuard-контур:

```text
Yandex VM                 WireGuard                 EU VPS
wg-eu 10.210.0.1/30  <-------------------->  wg-yandex 10.210.0.2/30
```

Проверено 2026-05-31:

- интерфейс `wg-eu` поднят на Yandex VM;
- интерфейс `wg-yandex` поднят на EU VPS;
- WireGuard handshake есть;
- default route на Yandex VM не меняется;
- full tunnel не включён;
- NAT на EU VPS относится к WireGuard-подсети, а не к домашним сервисам NASA.

Как можно использовать для NASA позже:

1. Как controlled admin path: доступ администратора к домашнему контуру через
   VPN без публикации Nextcloud/Immich/LLM Gateway напрямую в интернет.
2. Как будущий relay/bastion для SSH после отдельного risk-документа и
   отдельной настройки ключей.
3. Как внешний endpoint для WireGuard, если домашний провайдер не даёт белый IP.

Что не делать на Stage 0/Stage 1:

- не направлять весь домашний трафик через VPS без отдельного плана;
- не открывать Nextcloud, Immich, LLM Gateway или SSH на публичном IP;
- не смешивать текущий Yandex VM ↔ EU VPS туннель с домашним Jetson без
  отдельной схемы маршрутизации, firewall policy и rollback.

Минимальная будущая схема:

```text
Laptop admin client
        |
        | VPN
        v
VPS / VPN endpoint
        |
        | encrypted route only to admin ports
        v
Home router / Jetson LAN
        |
        v
Jetson: SSH, Nextcloud, Immich, LLM Gateway
```

Перед включением этой схемы нужно подготовить отдельный документ риска:

- какие порты доступны через VPN;
- какие ключи используются;
- какие маршруты добавляются;
- как отключить доступ;
- как проверить, что прямой public exposure отсутствует.

## 3.2. EU VPS — VPN-endpoint для NASA

Внешний WireGuard-endpoint, выбранный для удалённого админ-доступа к домашнему
контуру NASA. Это конец туннеля с белым IP; через него администратор заходит в
LAN к Jetson, не публикуя сервисы наружу.

| Параметр | Значение |
|---|---|
| Роль | Внешний VPN/WireGuard endpoint (admin path) |
| Публичный IP | `45.95.2.49` |
| Hostname | `weaselcloud-27011` |
| SSH-пользователь | `sshadmin` |
| SSH-alias | `vps-de` |
| SOCKS5-прокси | `45.95.2.49:40099` |
| WireGuard-порт | `51830/udp` |
| Туннельная подсеть | `10.210.0.0/30` |
| WG-адрес на EU VPS | `10.210.0.2/30` (интерфейс `wg-yandex`) |
| WG-адрес на втором конце (Yandex VM) | `10.210.0.1/30` (интерфейс `wg-eu`) |

> **Секреты вне репозитория.** SSH-ключ и WireGuard private/public ключи в git
> не хранятся (правило проекта «без секретов в git»). Они лежат в workspace вне
> NASA:
> - SSH-ключ EU VPS: `.master.env` → `SERVER_EU_VPS_SSH_KEY`;
> - WireGuard-ключи контура: `/home/alexey/work/Amnezia/secrets/id_sshadmin_vps`;
> - публичный ключ сервера: `.master.env` → `AMNEZIA_WG_SERVER_PUBLIC_KEY`.
>
> При развёртывании NASA-схемы поверх этого endpoint ключи и peer-конфиги
> подключаются локально, в репозиторий не попадают.

Подключение к EU VPS (из workspace, с загруженными секретами):

```bash
set -a; . /home/alexey/work/.master.env; set +a
ssh -i "$SERVER_EU_VPS_SSH_KEY" "${SERVER_EU_VPS_SSH_USER}@${SERVER_EU_VPS_HOST}"
```

Перед использованием этого endpoint для NASA по-прежнему нужен отдельный
risk-документ (см. конец §3.1): какие порты открыты через VPN, какие маршруты
добавляются и как откатить доступ.

## 3.3. Реализованная схема wg-nasa (2026-05-31, тестовый стенд)

> ⚠️ Статус: откачено 2026-05-31 из-за нестабильности через CGNAT (TCP не
> проходил), полностью удалено с VPS и Jetson — конфиги и ключи (2026-06-13)
> убраны и из `/etc/wireguard/wg-nasa.conf` на Jetson (бэкап в
> `/root/rollback-backup-2026-06-13/`). Раздел оставлен для истории/референса
> конфигурации (см. `TEST_STAND_CHECKPOINT_2026-05-31.md` §4.1, §6).

Поднят отдельный WireGuard-интерфейс `wg-nasa` на EU VPS — **изолированно** от
Amnezia-туннеля `wg-yandex` (порт 51830, не затронут).

| Узел | Параметры |
|---|---|
| EU VPS `45.95.2.49` | интерфейс `wg-nasa`, порт `51820/udp` (уже открыт в UFW), адрес `10.13.13.1/24`; форвардинг только внутри интерфейса (`-i wg-nasa -o wg-nasa`) |
| Jetson | пир `10.13.13.2/24`, Endpoint `45.95.2.49:51820`, AllowedIPs `10.13.13.0/24`, PersistentKeepalive 25 (нужен из-за CGNAT дома) |
| Клиент (телефон/ноут) | пир `10.13.13.3/24` |

Особенность Jetson: ядро L4T **4.9** не имеет встроенного WireGuard — модуль
собран через `wireguard-dkms` (заголовки ядра в составе `nvidia-l4t-kernel-headers`).
Хендшейк Jetson↔VPS подтверждён.

Доступ к сервисам извне: клиент поднимает WireGuard → VPS → Jetson, далее по
адресу `10.13.13.2` (Nextcloud `:8080`, Immich `:2283`, LLM Gateway `:8090`).
Прямого проброса портов нет (дома CGNAT, WAN `100.78.121.189`) — только этот
исходящий VPN-контур.

Ключи и приватные параметры — только в `.master.env` (`NASA_WG_*`), в git не
коммитятся.

## 4. DNS внутри сети

Минимально: доступ по IP.

Расширенно:

```text
cloud.home.arpa  -> 192.168.0.50
photos.home.arpa -> 192.168.0.50
llm.home.arpa    -> 192.168.0.50
```

## 5. Роутер

На домашнем роутере (модель уточняется на месте) выполнить:

1. Найти Jetson в DHCP-клиентах.
2. Закрепить IP, например `192.168.0.50`.
3. Проверить ping из LAN.
4. Не включать port forwarding на первом этапе.
