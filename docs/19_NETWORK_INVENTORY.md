# 19. Network Inventory

## 1. Purpose

This document records the home network layout for the NASA Home Cloud test stand.
It is a sanitized public inventory: real Wi-Fi passwords, router serial numbers,
router MAC addresses, and private credentials must stay in `config/.env`
(gitignored).

Scope of this step:

1. Observe current network state.
2. Record target topology for Jetson + USB HDD.
3. Keep router, firewall, VPN, DHCP, and Wi-Fi settings unchanged.
4. Mark items that still require router UI verification.

## 2. Safety Boundaries

- Do not change router DHCP, firewall, port forwarding, VPN, Wi-Fi, or ISP
  settings during inventory.
- Do not expose Nextcloud, Immich, LLM Gateway, Samba, or SSH directly to the
  internet.
- Do not touch the Amnezia server on the EU VPS through SSH or `wg set`.
- Use Tailscale for future external access unless a separate risk document
  explicitly approves another path.
- Treat router photos, SSIDs, passwords, MAC addresses, serial numbers, and
  admin credentials as secrets.

## 3. Target Topology

```text
Internet / ISP
    |
    v
Home router: TP-Link / Aginet EC220-G5
LAN: 192.168.0.0/24
Gateway: 192.168.0.1
    |
    +-- Windows laptop / admin workstation
    |      Wi-Fi client, current observed IP: 192.168.0.106
    |
    +-- Jetson Nano
           eth0: nasa-lan, static 192.168.0.50/24
           gateway: 192.168.0.1
           services: LAN-only
           |
           +-- USB HDD
                  data disk attached directly to Jetson over USB
                  not a network device

Future external admin access:

Admin client
    |
    v
Tailscale mesh / approved VPN path
    |
    v
Jetson Nano services on LAN

VPS:
    Stored as VPS_HOST in local secrets.
    Not an active public ingress path for home services without a separate risk doc.
```

## 4. Network Settings Table

| Component | Setting | Value | Source | Status |
|---|---|---|---|---|
| Home router | Vendor | TP-Link / Aginet | Router label photo | Observed |
| Home router | Model | EC220-G5 / EC220-G5(RU) | Router label photo + login page tab title | Observed |
| Home router | Hardware version | 2.20 | Router label photo | Observed |
| Home router | Admin URL | `http://192.168.0.1` | Router label photo + HTTP check | Verified reachable |
| Home router | HTTPS admin UI | `443/tcp` closed | `Test-NetConnection` | Observed |
| Home router | LAN gateway | `192.168.0.1` | Windows network config | Observed |
| Home router | LAN CIDR | `192.168.0.0/24` | Existing ADR + observed client IP | Accepted |
| Home router | Admin username | `HOME_ROUTER_ADMIN_USERNAME` | Local secret only | Assumed / needs confirmation |
| Home router | Admin password | `HOME_ROUTER_ADMIN_PASSWORD` | Local secret only | Missing / user input needed |
| Home router | MAC address | `HOME_ROUTER_MAC` | Router label photo | Secret, stored locally |
| Home router | Serial number | `HOME_ROUTER_SERIAL` | Router label photo | Secret, stored locally |
| Wi-Fi 2.4 GHz | SSID | `HOME_WIFI_SSID_2G` | Router label photo | Secret, stored locally |
| Wi-Fi 5 GHz | SSID | `HOME_WIFI_SSID_5G` | Router label photo | Secret, stored locally |
| Wi-Fi | Password / PIN | `HOME_WIFI_PASSWORD` | Router label photo | Secret, stored locally |
| Admin workstation | Current Wi-Fi IP | `192.168.0.106` | Windows network config | Observed |
| Jetson Nano | LAN profile | `nasa-lan` | ADR-0003 | Accepted, do not delete |
| Jetson Nano | LAN IP | `192.168.0.50/24` | ADR-0003 + local secrets | Target / needs LAN re-check |
| Jetson Nano | Gateway | `192.168.0.1` | ADR-0003 | Target / needs LAN re-check |
| Jetson Nano | USB recovery SSH | `admin@fe80::1%<ifIndex>` | Verified USB device-mode flow | Verified pattern |
| Jetson Nano | LAN SSH | `admin@192.168.0.50` | Target LAN path | Pending; currently not verified |
| USB HDD | Attachment | USB to Jetson Nano | User-confirmed target topology | Accepted |
| USB HDD | Network role | none | Storage architecture | Local block device only |
| USB HDD | Working mount | `/mnt/storage` | ADR-0002 | Only after storage migration decision |
| USB HDD | Existing-data intake mount | `/mnt/hdd-check` read-only | Storage design | Use before migration |
| Nextcloud | LAN port | `8080/tcp` | Compose/docs | LAN-only |
| Immich | LAN port | `2283/tcp` | Compose/docs | LAN-only |
| LLM Gateway | LAN port | `8090/tcp` | Compose/docs | LAN-only |
| Samba | LAN port | `445/tcp` | Samba design | LAN-only |
| SSH | LAN port | `22/tcp` | Jetson admin | LAN/VPN-only |
| VPS | Host | `VPS_HOST` | `config/.env` | Secret/local operational value |
| VPS | User | `VPS_USER` | `config/.env` | Secret/local operational value |
| VPS | SSH key | `VPS_SSH_KEY` | `config/.env` | Secret/local operational value |
| External access | Preferred path | Tailscale | ADR-0004 | Planned |
| Public port forwarding | Home router | none for Stage 1 | ADR-0003 | Required safe default |

## 5. Router UI Status

The router web UI is reachable at `http://192.168.0.1` and returns the TP-Link
login page. The current screenshot shows a password-only login form. The page
uses client-side encryption before submitting login data.

Current limitation:

- `HOME_ROUTER_ADMIN_USERNAME` is recorded locally as an assumption, not as a
  router-UI-verified value.
- `HOME_ROUTER_ADMIN_PASSWORD` is not known yet.
- The Wi-Fi password/PIN from the label must not be assumed to be the router
  admin password unless confirmed by the user.

Router UI verification is therefore pending. When the admin password is
available, inspect only these read-only pages:

1. LAN IP/subnet.
2. DHCP server enabled/disabled and DHCP range.
3. DHCP reservation/static lease for Jetson `192.168.0.50`.
4. Connected clients list.
5. Port forwarding / virtual servers list.
6. UPnP state.
7. Firewall remote management state.
8. Wi-Fi SSIDs/security mode.

Do not save or apply any router setting changes during this inventory.

## 6. Validation Commands

From Windows admin workstation:

```powershell
Get-NetIPConfiguration
Test-NetConnection 192.168.0.1 -Port 80
Test-NetConnection 192.168.0.1 -Port 443
Test-NetConnection 192.168.0.50 -Port 22
arp -a
```

From Windows USB recovery path to Jetson:

```powershell
Get-NetAdapter
ping -6 fe80::1%<ifIndex>
Test-NetConnection -ComputerName "fe80::1%<ifIndex>" -Port 22
ssh admin@fe80::1%<ifIndex>
```

From Jetson after LAN cable is connected:

```bash
ip -br addr show eth0
ip route
nmcli connection show nasa-lan
ping -c 3 192.168.0.1
```

Storage check after HDD is attached to Jetson:

```bash
lsblk -o NAME,TYPE,SIZE,FSTYPE,LABEL,MOUNTPOINT,MODEL,TRAN,RO
mountpoint /mnt/storage || echo "/mnt/storage is not mounted"
```

## 7. Current Open Items

| Item | Why it matters | Next safe action |
|---|---|---|
| Router admin password missing | DHCP range and static lease cannot be verified from UI | User provides/admin enters password; inspect only |
| Jetson LAN not verified in this pass | Jetson target path is LAN, not USB | Connect Jetson to router LAN and test `192.168.0.50:22` |
| HDD currently being sorted by user | Storage migration depends on final retained data size | Re-scan HDD after cleanup |
| 250 GB resource unavailable | Cannot plan final copy destination yet | Connect 250 GB resource and inventory it |
| External access not active | CGNAT and Amnezia constraints | Follow Tailscale plan, no router port forwarding |

## 8. Rollback

This inventory step does not change router or Jetson network settings.

If a future router UI session accidentally opens an edit form, leave the page
without saving. If a future Jetson LAN change breaks access, use USB recovery:

```powershell
ssh admin@fe80::1%<ifIndex>
```
