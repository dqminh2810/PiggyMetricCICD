#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker admin
mkdir -p /home/admin/jenkins_home
chown -R admin:admin /home/admin/jenkins_home

cat > /home/admin/docker-compose.yml <<EOF
version: '3.8'
services:
  jenkins:
    container_name: jenkins_controller
    image: jenkins/jenkins:lts
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - "/home/admin/jenkins_home:/var/jenkins_home"    
    restart: unless-stopped
EOF

cd /home/admin
sudo docker-compose up -d