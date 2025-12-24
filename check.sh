#!/bin/bash

TAG="user-13-70"
BASE_DIR="/var/lib/KySKuS-checker"
BASELINE="$BASE_DIR/baseline.sha256"
mkdir -p "$BASE_DIR"

if [[ ! -f "$BASELINE" ]]; then
    sha256sum /etc/passwd /etc/group /etc/sudoers > "$BASELINE"
    chmod 600 "$BASELINE"
    chown root:root "$BASELINE"
fi

while true; do
    if ! sha256sum -c "$BASELINE" --quiet 2>/dev/null; then
        logger -t "$TAG" "Изменены файлы: $(sha256sum -c "$BASELINE" 2>/dev/null | grep -v OK | cut -d: -f1 | tr '\n' ' ')"
    fi
    sleep 60
done
