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
resource "aws_key_pair" "jenkins_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Create a security group
resource "aws_security_group" "jenkins_sg" {
# Allow external traffic for port 22 (ssh) & 8080 (jenkins server)
  name_prefix = "jenkins-sg-"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
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
#   # Allow agent to connect to controller (Jnlp port)
#   ingress {
#     from_port   = 50000
#     to_port     = 50000
#     protocol    = "tcp"
#     cidr_blocks = [aws_instance.jenkins_agent.private_ip_address]
#   }
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the EC2 instance for the jenkins controller
# t3 for amd64 - t4 for arm64
resource "aws_instance" "jenkins_controller" {
  # ami           = "ami-01a45e82be7773160"
  # instance_type = "t4g.medium"
  ami           = "ami-0818ff4e4d072e0ec"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  # user_data     = file("base-setup/install-jenkins-controller.sh")

  tags = {
    Name = "jenkins-controller"
  }
}

# Create the EC2 instance(s) for the jenkins agent(s)
# t3 for amd64 - t4 for arm64
resource "aws_instance" "jenkins_agents" {
  count = var.agent_count
  # ami           = "ami-01a45e82be7773160"
  # instance_type = "t4g.small"
  ami           = "ami-0818ff4e4d072e0ec"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  # user_data     = file("base-setup/install-jenkins-agent.sh")

  tags = {
    Name = "jenkins-agent-${count.index + 1}"
  }
}

# setup jenkins controller
resource "null_resource" "setup-jenkins-controller" {
  depends_on = [aws_instance.jenkins_controller]
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting 60 seconds for SSH service to start..."
      sleep 60

      export ANSIBLE_HOST_KEY_CHECKING=False
      ansible-playbook -i "${aws_instance.jenkins_controller.public_ip}," ./ansible/playbook-jenkins-controller.yaml \
        --user admin \
        --private-key ${var.private_key_path}
    EOT
  }
}

# setup jenkins agents
resource "null_resource" "setup-jenkins-agents" {
  depends_on = [aws_instance.jenkins_agents]
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting 60 seconds for SSH service to start..."
      sleep 60

      export ANSIBLE_HOST_KEY_CHECKING=False
      ANSIBLE_HOSTS="${join(",", aws_instance.jenkins_agents[*].public_ip)},"
      ansible-playbook -i $ANSIBLE_HOSTS ./ansible/playbook-jenkins-agent.yaml \
        --user admin \
        --private-key ${var.private_key_path}
    EOT
  }
}

# extract the password from the jenkins controller
resource "null_resource" "get_jenkins_controller_initial_password" {
  depends_on = [null_resource.setup-jenkins-controller]

  provisioner "local-exec" {
    command = "sleep 60 && ssh -v -o StrictHostKeyChecking=no -i ${var.private_key_path} admin@${aws_instance.jenkins_controller.public_ip} 'sudo head -c -1 /home/admin/jenkins_home/secrets/initialAdminPassword' > tmp/jenkins_controller_initial_password"
  }
}

data "local_file" "jenkins_controller_initial_password_file" {
  filename = "tmp/jenkins_controller_initial_password"
  depends_on = [null_resource.get_jenkins_controller_initial_password]
}