#!/bin/bash
## Install Docker
sudo apt-get update -y
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker admin

## Install Java
cd ~/
wget https://download.oracle.com/java/21/archive/jdk-21_linux-x64_bin.deb
sudo dpkg -i jdk-21_linux-x64_bin.deb
echo "export PATH=$PATH:/usr/lib/jvm/jdk-21.0.8-oracle-x64/bin" >> ~/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/jdk-21.0.8-oracle-x64" >> ~/.bashrc
source ~/.bashrc
sudo rm ~/jdk-21_linux-x64_bin.deb

## Install Maven
sudo apt-get install -y maven

## Install prometheus-node-exporter 
sudo apt-get install -y prometheus-node-exporter