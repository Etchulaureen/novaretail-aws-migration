#!/usr/bin/env bash
set -euxo pipefail
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx curl
cat >/var/www/html/index.html <<'EOF'
<!doctype html><html><head><meta charset="utf-8"><title>NovaRetail</title></head><body><h1>NovaRetail AWS Migration Lab</h1><p>Status: healthy</p><p>Provisioned with Terraform.</p><p>Project: ${project_name}</p></body></html>
EOF
systemctl enable nginx
systemctl restart nginx
