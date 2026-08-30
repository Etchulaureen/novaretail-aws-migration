#!/usr/bin/env bash
set -euxo pipefail

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io curl unzip

systemctl enable docker
systemctl start docker

cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install

mkdir -p /opt/novaretail

aws s3 cp s3://${bucket_name}/app/app.py /opt/novaretail/app.py
aws s3 cp s3://${bucket_name}/app/requirements.txt /opt/novaretail/requirements.txt
aws s3 cp s3://${bucket_name}/app/Dockerfile /opt/novaretail/Dockerfile

cd /opt/novaretail

docker build -t novaretail-app .

docker run -d \
  --name novaretail-app \
  --restart unless-stopped \
  -p 8080:8080 \
  -e APP_ENV=${environment} \
  novaretail-app
