#!/bin/bash
CONFIG_FILE="/etc/KySKuS_checker.conf"
#изначальный конфиг
INTERVAL=60
FILES=("/etc/passwd" "/etc/group" "/etc/sudoers")
LOG_ENABLED=true
TAG="user-13-70"
BACKUP_DIR="/var/lib/check/backups"
#подгруз конфига
if [[ -f "$CONFIG_FILE" ]]; then
    while IFS='=' read -r key val; do
        if [[ "$key" =~ ^[A-Z_]+$ && -n "$val" ]]; then
            case "$key" in
                INTERVAL) INTERVAL="$val" ;;
                FILES) IFS=',' read -r -a FILES <<< "$val" ;;
                LOG_ENABLED) LOG_ENABLED="$val" ;;
            esac
        fi
    done < <(grep -E '^[A-Z_]+=' "$CONFIG_FILE")
fi
#эталон и резервные копии
BASE_DIR="/var/lib/check"
BASELINE="$BASE_DIR/baseline.sha256"
mkdir -p "$BASE_DIR" "$BACKUP_DIR"
if [[ ! -f "$BASELINE" ]]; then
    for file in "${FILES[@]}"; do
        if [[ -f "$file" ]]; then
            cp "$file" "$BACKUP_DIR/$(basename "$file").orig"
        fi
    done
    sha256sum "${FILES[@]}" > "$BASELINE"
    chmod 600 "$BASELINE"
    chown root:root "$BASELINE"
fi
#основной цикл 
while true; do
    if ! sha256sum -c "$BASELINE" --quiet 2>/dev/null; then
        if [[ "$LOG_ENABLED" == true ]]; then
            while IFS= read -r file; do
                if [[ -f "$file" ]]; then
                    basename_file=$(basename "$file")
                    orig="$BACKUP_DIR/$basename_file.orig"
                    owner=$(stat -c '%U' "$file")
                    if [[ -f "$orig" ]]; then
                        diff_out=$(diff -u "$orig" "$file" 2>/dev/null | head -n 10)
                        logger -t "$TAG" "Файл '$file' изменён! Владелец: $owner. Изменения: $diff_out"
                    else
                        logger -t "$TAG" "Файл '$file' изменён! Владелец: $owner (резервная копия отсутствует)"
                    fi
                fi
            done < <(sha256sum -c "$BASELINE" 2>/dev/null | grep -v ": OK$" | cut -d: -f1)
        fi
    fi
    sleep "$INTERVAL"
done
