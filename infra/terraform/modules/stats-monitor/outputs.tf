output "metrics_ip_addr" {
  description = "Internal IP address of the VPC's metrics instance. Deployer can SSH tunnel into this instance."
  value       = aws_instance.metrics.private_ip
}