from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
    )

    api_port: int = 8099
    api_log_level: str = "INFO"

    # Log file inside container — mount as volume to persist on host
    log_file: str = "/var/log/nasa-monitor/nasa-api.jsonl"
    log_max_bytes: int = 10 * 1024 * 1024  # 10 MB per file
    log_backup_count: int = 5

    # Space-separated list of expected container names
    expected_containers: str = (
        "homecloud-nextcloud-nextcloud-1 "
        "homecloud-immich-immich-server-1 "
        "homecloud-llm-gateway-llm-gateway-1 "
        "homecloud_netdata "
        "homecloud_uptime_kuma "
        "homecloud_portainer"
    )

    # Telegram report integration
    report_cmd: str = "/usr/local/sbin/nasa-send-report-telegram.sh"

    # Services to HTTP-check
    local_services: str = (
        "Nextcloud=http://host.docker.internal:8080/ "
        "Immich=http://host.docker.internal:2283/ "
        "LLM-Gateway=http://host.docker.internal:8090/health"
    )


settings = Settings()
