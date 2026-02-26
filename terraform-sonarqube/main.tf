# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create a new key pair for SSH access
resource "aws_key_pair" "sonarqube_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Create a security group
resource "aws_security_group" "sonarqube_sg" {
# Allow external traffic for port 22 (ssh) & 9000 (sonarqube server)
  name_prefix = "sonarqube-sg-"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow traffic from all nodes in the security group
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the EC2 instance for the sonarqube server
# t3 for amd64 - t4 for arm64
resource "aws_instance" "sonarqube_server" {
  ami           = "ami-0818ff4e4d072e0ec"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.sonarqube_key.key_name
  vpc_security_group_ids = [aws_security_group.sonarqube_sg.id]
  user_data     = file("base-setup/install-sonarqube.sh")

  tags = {
    Name = "sonarqube-server"
  }
}