# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create a new key pair for SSH access
resource "aws_key_pair" "metric_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Create a security group
resource "aws_security_group" "metric_sg" {
# Allow external traffic for port 22 (ssh) & 9090 (prometheus server) & 3000 (grafana server)
  name_prefix = "jenkins-sg-"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 3000
    to_port     = 3000
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

# Create the EC2 instance for the metric server
# t3 for amd64 - t4 for arm64
resource "aws_instance" "metric_server" {
  # ami           = "ami-01a45e82be7773160"
  # instance_type = "t4g.medium"
  ami           = "ami-0883a1956e6e2539b"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.metric_key.key_name
  vpc_security_group_ids = [aws_security_group.metric_sg.id]
  user_data     = file("base-setup/install-metric-server.sh")

  tags = {
    Name = "jenkins-controller"
  }
}