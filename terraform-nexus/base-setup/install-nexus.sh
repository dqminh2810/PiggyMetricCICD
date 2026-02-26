#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker admin

cat > /home/admin/docker-compose.yml <<EOF
version: '3.8'
services:
  nexus:
    container_name: nexus_server
    image: sonatype/nexus3:latest
    ports:
      - "8081:8081"
#    volumes:
#      - "nexus-data:/nexus-data" # Mount the volume for persistent data
    restart: unless-stopped
EOF

cd /home/admin
sudo docker-compose up -d