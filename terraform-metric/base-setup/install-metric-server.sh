#!/bin/bash
## Install Docker
sudo apt-get update -y
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker admin

cat > /home/admin/docker-compose.yml <<EOF
scrape_configs:
  - job_name: 'jenkins-controller'
    metrics_path: '/prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['<jenkins-controller-host-IP>:<jenkins-controller-port>']

  - job_name: 'jenkins-agent-node'
    metrics_path: '/metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['<jenkins-agent-host-IP>:9001']
EOF


cat > /home/admin/docker-compose.yml <<EOF
version: '3.8'
services:
  prometheus:
    image: "prom/prometheus"
    container_name: prometheus
    volumes:
      - /home/admin/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
  grafana:
    image: "grafana/grafana"
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - /home/admin/grafana/data:/var/lib/grafana
    environment:
    # These environment variables will override corresponding settings in grafana.ini
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=password
    user: "0"
EOF

cd /home/admin
sudo docker-compose up -d