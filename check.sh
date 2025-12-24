#!/bin/bash

CONFIG_FILE="/etc/KySKuS_checker.conf"
TAG="user-13-70"

# Папка для хранения резервных 
BACKUP_DIR="/var/lib/check/backups"
BASELINE="/var/lib/check/baseline.sha256"

#по умолчанию
INTERVAL=10
FILES=("/etc/passwd" "/etc/group" "/etc/sudoers")
LOG_ENABLED=true

# конфиг
if [[ -f "$CONFIG_FILE" ]]; then
    while IFS='=' read -r key val; do
        [[ "$key" =~ ^[A-Z_]+$ && -n "$val" ]] || continue
        case "$key" in
            INTERVAL) INTERVAL="$val" ;;
            FILES) IFS=',' read -r -a FILES <<< "$val" ;;
            LOG_ENABLED) LOG_ENABLED="$val" ;;
        esac
    done < <(grep -E '^[A-Z_]+=' "$CONFIG_FILE")
fi

#структура
mkdir -p "$BACKUP_DIR"

# резервные копии и первый эталон 
if [[ ! -s "$BASELINE" ]]; then
    for file in "${FILES[@]}"; do
        if [[ -f "$file" ]]; then
            cp "$file" "$BACKUP_DIR/$(basename "$file").orig"
        fi
    done
    sha256sum "${FILES[@]}" > "$BASELINE"
    chmod 600 "$BASELINE"
    chown root:root "$BASELINE"
fi

# краткое описание изменений
get_diff_summary() {
    local file="$1"
    local orig="$BACKUP_DIR/$(basename "$file").orig"
    local temp_new="/tmp/check_new_$$"

    if [[ ! -f "$orig" ]]; then
        echo " (new file)"
        cp "$file" "$orig"
        return
    fi

    cp "$file" "$temp_new"
    local diff_out
    diff_out=$(diff -u "$orig" "$temp_new" 2>/dev/null)

    if [[ -z "$diff_out" ]]; then
        echo " (no changes)"
        rm -f "$temp_new"
        return
    fi

    # Анализ diff
    local added=0 removed=0
    while IFS= read -r line; do
        if [[ "$line" == +* && "$line" != "++"* ]]; then
            ((added++))
        elif [[ "$line" == -* && "$line" != "--"* ]]; then
            ((removed++))
        fi
    done <<< "$diff_out"

    local summary=""
    if [[ $added -gt 0 ]]; then
        summary+=" +$added line(s)"
    fi
    if [[ $removed -gt 0 ]]; then
        summary+=" -$removed line(s)"
    fi

    # Обновляем резервную копию
    cp "$file" "$orig"
    rm -f "$temp_new"

    echo " ($summary)"
}

# Основной
while true; do
    if ! sha256sum -c "$BASELINE" --quiet 2>/dev/null; then
        if [[ "$LOG_ENABLED" == true ]]; then
            while IFS=':' read -r file _; do
                if [[ -n "$file" && -f "$file" ]]; then
                    summary=$(get_diff_summary "$file")
                    logger -t "$TAG" "Изменён файл: $file$summary"
                fi
            done < <(sha256sum -c "$BASELINE" 2>/dev/null | grep -v ": OK$")
        fi
    fi
    sleep "$INTERVAL"
done
