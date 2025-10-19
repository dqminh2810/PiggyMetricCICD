# terraform {
#     required_providers {
#         docker = {
#         source = "kreuzwerker/docker"
#         version = "~> 3.0.1"
#         }
#     }
# }

# provider "docker" {
#     host = "unix:///var/run/docker.sock"
# }

# resource "docker_image" "jenkins_controller" {
#     name         = "jenkins/jenkins:lts"
#     keep_locally = true
# }

# resource "docker_image" "jenkins_agent" {
#     name         = "jenkins-agent:latest"
#     keep_locally = true
#     # build {
#     #     context    = "./jenkins-agent"
#     #     dockerfile = "Dockerfile"
#     #     tag        = ["jenkins/ssh-agent:jdk17"]
#     # }
# }

# resource "docker_container" "jenkins-controller" {
#     image = docker_image.jenkins_controller.image_id
#     name  = "jenkins-controller"
#     privileged = true
#     user = "root"
#     volumes {
#         host_path       = abspath("./jenkins-controller/data")
#         container_path  = "/var/jenkins_home"
#     }
#     volumes {
#         host_path       = abspath("/var/run/docker.sock")
#         container_path  = "/var/run/docker.sock"
#     }
#     ports {
#         internal = 8080
#         external = 9091
#     }
#     ports {
#         internal = 50000
#         external = 50000
#     }
#     env = [
#         "DOCKER_HOST=unix:///var/run/docker.sock"
#     ]
#     restart = "on-failure"
# }

# resource "docker_container" "jenkins-agent" {
#     image = docker_image.jenkins_agent.image_id
#     name  = "jenkins-agent"
#     privileged = true
#     user = "root"
#     volumes {
#         host_path       = abspath("./jenkins-agent/ssh/jenkins-agent.pub")
#         container_path  = "/home/jenkins/.ssh/authorized_keys"
#     }
#     volumes {
#         host_path       = abspath("/var/run/docker.sock")
#         container_path  = "/var/run/docker.sock"
#     }
#     ports {
#         internal = 22
#         external = 22
#     }
#     ports {
#         internal = 9001
#         external = 9100
#     }
#     env = [
#         "DOCKER_HOST=unix:///var/run/docker.sock"
#     ]
# }