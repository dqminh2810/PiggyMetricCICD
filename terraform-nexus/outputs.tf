output "nexus_server_public_ip" {
  description = "The public IP address of the nexus server."
  value       = aws_instance.nexus_server.public_ip
}

output "nexus_server_public_dns" {
  description = "The public dns of the nexus server."
  value       = aws_instance.nexus_server.public_dns
}