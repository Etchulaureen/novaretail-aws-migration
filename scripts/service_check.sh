#!/usr/bin/env bash
set -euo pipefail

CONTAINER="${1:-novaretail-app}"

if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  echo "PASS: container $CONTAINER is running"
else
  echo "FAIL: container $CONTAINER is not running"
  docker ps -a
  exit 1
fi
