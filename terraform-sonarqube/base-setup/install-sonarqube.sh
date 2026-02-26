#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker admin

cat > /home/admin/docker-compose.yml <<EOF
version: '3.8'
services:
  sonarqube:
    container_name: sonarqube_server
    image: sonarqube:lts-community
    ports:
      - "9000:9000"
#    volumes:
#      - sonarqube_conf:/opt/sonarqube/conf
#      - sonarqube_data:/opt/sonarqube/data
#      - sonarqube_extensions:/opt/sonarqube/extensions
#      - sonarqube_logs:/opt/sonarqube/logs
    restart: unless-stopped
EOF

cd /home/admin
sudo docker-compose up -d