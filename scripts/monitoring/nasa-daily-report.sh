#!/usr/bin/env bash
# NASA Home Cloud — daily health report (Jetson Nano)
set -u

CONF="/etc/nasa-monitor/nasa-monitor.env"
[ -f "$CONF" ] && . "$CONF"

NOW_UTC="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
NOW_MSK="$(TZ='Europe/Moscow' date '+%Y-%m-%d %H:%M:%S MSK')"
HOST="$(hostname)"
LOAD="$(cut -d' ' -f1-3 /proc/loadavg)"
UPTIME="$(uptime -p 2>/dev/null || uptime)"

DISK_ROOT_LINE="$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
DISK_ROOT_PCT="$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')"

DISK_STORAGE_LINE="not mounted"
DISK_STORAGE_PCT=0
if mountpoint -q /mnt/storage 2>/dev/null; then
    DISK_STORAGE_LINE="$(df -h /mnt/storage | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
    DISK_STORAGE_PCT="$(df -P /mnt/storage | awk 'NR==2 {gsub("%","",$5); print $5}')"
fi

RAM_LINE="$(free -h | awk '/Mem:/ {print $3 " / " $2 " (avail " $7 ")"}')"
RAM_AVAIL_MB="$(free -m | awk '/Mem:/ {print $7}')"

# Jetson thermal zones
TEMP_REPORT=""
for zone in /sys/class/thermal/thermal_zone*/; do
    name="$(cat "${zone}type" 2>/dev/null || echo unknown)"
    temp_raw="$(cat "${zone}temp" 2>/dev/null || echo 0)"
    temp_c="$((temp_raw / 1000))"
    case "$name" in
        CPU-therm|GPU-therm|PLL-therm|AO-therm|PMIC-Die|thermal-fan-est)
            TEMP_REPORT="${TEMP_REPORT}  ${name}: ${temp_c}°C\n"
            ;;
    esac
done
[ -z "$TEMP_REPORT" ] && TEMP_REPORT="  (thermal zones unavailable)\n"

# Services
TUNNEL_STATE="$(systemctl is-active nasa-tunnel.service 2>/dev/null || echo unknown)"
DOCKER_STATE="$(systemctl is-active docker 2>/dev/null || echo unknown)"
NM_STATE="$(systemctl is-active NetworkManager 2>/dev/null || echo unknown)"

# Containers
EXPECTED_CONTAINERS="${EXPECTED_CONTAINERS:-homecloud-nextcloud-nextcloud-1 homecloud-immich-immich-server-1 homecloud-llm-gateway-llm-gateway-1 homecloud_netdata homecloud_uptime_kuma homecloud_portainer}"

CONTAINER_REPORT=""
WARNINGS=""

add_warning() { WARNINGS="${WARNINGS}\n  ⚠️  $1"; }

for c in $EXPECTED_CONTAINERS; do
    status="$(docker inspect "$c" --format '{{.State.Status}}' 2>/dev/null || echo missing)"
    restarts="$(docker inspect "$c" --format '{{.RestartCount}}' 2>/dev/null || echo ?)"
    icon="✅"
    [ "$status" != "running" ] && { icon="❌"; add_warning "container ${c} is ${status}"; }
    short="${c#homecloud-}"
    short="${short#homecloud_}"
    CONTAINER_REPORT="${CONTAINER_REPORT}\n  ${icon} ${short}: ${status} (restarts: ${restarts})"
done

# HTTP checks (local)
http_check() {
    local url="$1" label="$2"
    code="$(curl -o /dev/null -s -w '%{http_code}' --max-time 5 "$url" 2>/dev/null || echo 000)"
    if [ "$code" = "200" ] || [ "$code" = "302" ]; then
        echo "  ✅ ${label}: HTTP ${code}"
    else
        echo "  ❌ ${label}: HTTP ${code}"
        add_warning "${label} returned HTTP ${code}"
    fi
}

HTTP_REPORT=""
HTTP_REPORT="${HTTP_REPORT}\n$(http_check "http://localhost:8080/" "Nextcloud")"
HTTP_REPORT="${HTTP_REPORT}\n$(http_check "http://localhost:2283/" "Immich")"
HTTP_REPORT="${HTTP_REPORT}\n$(http_check "http://localhost:8090/health" "LLM Gateway")"
HTTP_REPORT="${HTTP_REPORT}\n$(http_check "http://localhost:19999/" "Netdata")"

# External check via VPS (optional)
EXTERNAL_REPORT=""
VPS="${SERVER_IP:-193.8.215.130}"
ext_code="$(curl -o /dev/null -s -w '%{http_code}' --max-time 8 "http://${VPS}:8080/" 2>/dev/null || echo 000)"
if [ "$ext_code" = "200" ] || [ "$ext_code" = "302" ]; then
    EXTERNAL_REPORT="  ✅ VPS relay (${VPS}:8080): HTTP ${ext_code}"
else
    EXTERNAL_REPORT="  ❌ VPS relay (${VPS}:8080): HTTP ${ext_code}"
    add_warning "VPS relay unreachable (${ext_code}) — tunnel may be down"
fi

# Threshold warnings
[ "$DISK_ROOT_PCT" -ge "${DISK_WARN_PERCENT:-80}" ] && \
    add_warning "root disk usage high: ${DISK_ROOT_PCT}%"
[ "$DISK_STORAGE_PCT" -ge "${DISK_WARN_PERCENT:-80}" ] && \
    add_warning "storage disk usage high: ${DISK_STORAGE_PCT}%"
[ "$RAM_AVAIL_MB" -lt "${RAM_WARN_MB:-300}" ] && \
    add_warning "available RAM low: ${RAM_AVAIL_MB} MB"
[ "$TUNNEL_STATE" != "active" ] && \
    add_warning "nasa-tunnel.service is ${TUNNEL_STATE}"
[ "$DOCKER_STATE" != "active" ] && \
    add_warning "docker.service is ${DOCKER_STATE}"

WARN_SECTION=""
if [ -n "$WARNINGS" ]; then
    WARN_SECTION="$(printf "\n⚠️  WARNINGS%b" "$WARNINGS")"
fi

cat <<REPORT
🏠 NASA HOME CLOUD — Daily Report
📅 ${NOW_MSK}

💻 SYSTEM — ${HOST}
  Uptime: ${UPTIME}
  Load: ${LOAD}
  RAM: ${RAM_LINE}
  Disk /: ${DISK_ROOT_LINE}
  Disk /mnt/storage: ${DISK_STORAGE_LINE}

🌡  TEMPERATURE
$(printf "%b" "$TEMP_REPORT")
🔌 SERVICES
  NASA tunnel: ${TUNNEL_STATE}
  Docker: ${DOCKER_STATE}
  NetworkManager: ${NM_STATE}

🐳 CONTAINERS
$(printf "%b" "$CONTAINER_REPORT")

🌐 LOCAL HTTP
$(printf "%b" "$HTTP_REPORT")

☁️  EXTERNAL ACCESS
${EXTERNAL_REPORT}
${WARN_SECTION}
REPORT
