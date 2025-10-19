output "jenkins_controller_public_ip" {
  description = "The public IP address of the jenkins controller."
  value       = aws_instance.jenkins_controller.public_ip
}

output "jenkins_controller_public_dns" {
  description = "The public dns of the jenkins controller."
  value       = aws_instance.jenkins_controller.public_dns
}

output "jenkins_agent_public_ips" {
  description = "The public IP addresses of the jenkins agents."
  value       = aws_instance.jenkins_agents[*].public_ip
}

output "jenkins_controller_initial_password" {
  description = "Jenkins controller initial admin password"
  value       = data.local_file.jenkins_controller_initial_password_file.content
}