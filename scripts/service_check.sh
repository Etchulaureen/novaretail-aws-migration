#!/usr/bin/env bash
set -euo pipefail
SERVICE="${1:-nginx}"
if systemctl is-active --quiet "$SERVICE"; then
  echo "PASS: $SERVICE is active"
else
  echo "FAIL: $SERVICE is not active"
  systemctl status "$SERVICE" --no-pager || true
  exit 1
fi
