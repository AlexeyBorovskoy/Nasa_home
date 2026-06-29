---
layout: default
title: Android Client Setup
---

# Android client setup

## Apps installed

| App | Purpose | Store |
|---|---|---|
| Immich | Photo auto-backup | Play Store |
| Nextcloud | File sync, WebDAV | Play Store |
| DAVx⁵ | CalDAV + CardDAV (contacts, calendar) | APK v4.5.14 |

## Immich

Connect to: `http://YOUR_VPS_IP:2283` (external) or `http://192.168.x.x:2283` (LAN)

1. Open Immich → Settings → Backup → enable auto-backup
2. On MIUI/HyperOS: add to battery whitelist + allow auto-start (otherwise backup stops in background)
3. Current backup: 6 697 photos and videos

LAN URL (faster, WiFi only): Settings → Network → add `http://192.168.x.x:2283`

## Nextcloud

Connect to: `https://YOUR_VPS_IP:8443`

1. Accept the self-signed certificate warning (press the small link below the error)
2. Login with your account credentials
3. Enable auto-upload for photos if needed (separate from Immich)

## DAVx⁵

Requires HTTPS — that's why self-signed TLS was needed even before a domain.

1. Open DAVx⁵ → Add account → Login with URL and user
2. Base URL: `https://YOUR_VPS_IP:8443/remote.php/dav`
3. Accept the self-signed certificate
4. Enable CalDAV (calendar) and CardDAV (contacts)
5. Android Settings → Accounts → sync manually or set interval

Result: contacts and calendar sync between all family phones through Nextcloud.

## Notes on MIUI/HyperOS

Xiaomi phones aggressively kill background processes.  
Without the following, backup and sync will stop working after the screen turns off:

- Battery → App power usage → Immich/Nextcloud/DAVx⁵ → No restrictions
- Security → Auto-start → enable for all three apps
- Recent apps → lock the app (swipe-hold to pin)

## Self-signed certificate — one-time warning

Both Nextcloud and DAVx⁵ will show a certificate warning on first connect.  
Tap "Accept" / "Trust this certificate" — stored permanently for that app.

---

[← Reliability](reliability.md) | [Evidence →](evidence.md)
