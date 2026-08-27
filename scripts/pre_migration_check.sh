#!/usr/bin/env bash
set -u
SOURCE_HOST="${1:-example.com}"
BACKUP_FILE="${2:-/tmp/novaretail-backup.tar.gz}"
FAILED=0

echo "=== NovaRetail Pre-Migration Check ==="

if getent hosts "$SOURCE_HOST" >/dev/null 2>&1; then echo "PASS DNS"; else echo "WARN DNS"; FAILED=1; fi
if curl -fsS --max-time 10 "https://${SOURCE_HOST}" >/dev/null 2>&1; then echo "PASS HTTPS"; else echo "WARN HTTPS"; FAILED=1; fi

echo "--- Disk ---"; df -h /
echo "--- Memory ---"; command -v free >/dev/null && free -h || true

if [[ -f "$BACKUP_FILE" ]]; then echo "PASS backup exists: $BACKUP_FILE"; else echo "WARN backup missing: $BACKUP_FILE"; FAILED=1; fi

exit "$FAILED"
