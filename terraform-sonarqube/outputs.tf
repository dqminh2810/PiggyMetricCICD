output "sonarqube_server_public_ip" {
  description = "The public IP address of the sonarqube server."
  value       = aws_instance.sonarqube_server.public_ip
}

output "sonarqube_server_public_dns" {
  description = "The public dns of the sonarqube server."
  value       = aws_instance.sonarqube_server.public_dns
}