output "metric_public_ip" {
  description = "The public IP address of the metric server."
  value       = aws_instance.metric_server.public_ip
}
